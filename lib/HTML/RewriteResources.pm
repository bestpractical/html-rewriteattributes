#!/usr/bin/env perl
package HTML::RewriteResources;
use strict;
use warnings;
use base 'HTML::Parser';
use Carp 'croak';

our $VERSION = '0.01';

sub new {
    my $class = shift;
    return $class->SUPER::new(
        start_h   => [ \&_start_tag, "self,tagname,attr,attrseq,text" ],
        default_h => [ \&_default,   "self,tagname,attr,text"         ],
    );
}

sub rewrite {
    my $self = shift;
    $self = $self->new if !ref($self);

    my $html = shift;
    my $cb   = shift || sub { $self->rewrite_resource(@_) };

    $self->_begin_rewriting($cb);

    $self->parse($html);
    $self->eof;

    $self->_done_rewriting;

    return $self->{rewrite_html};
}

sub rewrite_resource {
    my $self = shift;
    my $class = ref($self) || $self;

    my $error = "You must specify a callback to $class->rewrite";
    $error .= " or define $class->rewrite_resource" if $class ne __PACKAGE__;
    croak "$error.";
}

sub _begin_rewriting {
    my $self = shift;
    my $cb   = shift;

    $self->{rewrite_html} = '';
    $self->{rewrite_callback} = $cb;
}

sub _done_rewriting { }

my %rewritable_attrs = (
    bgsound => [ qw/src       / ],
    body    => [ qw/background/ ],
    img     => [ qw/src       / ],
    input   => [ qw/src       / ],
    table   => [ qw/background/ ],
    td      => [ qw/background/ ],
    th      => [ qw/background/ ],
    tr      => [ qw/background/ ],
);

sub _rewritable_attrs {
    my $self = shift;
    my $tag  = shift;

    return @{ $rewritable_attrs{$tag} || [] }
}

sub _start_tag {
    my ($self, $tagname, $attrs, $attrseq, $text) = @_;

    my @rewritable = $self->_rewritable_attrs($tagname);

    for my $attr (@rewritable) {
        next unless exists $attrs->{$attr};
        $attrs->{$attr} = $self->{rewrite_callback}->($attrs->{$attr});
    }

    $self->{rewrite_html} .= "<$tagname";

    for my $attr (@$attrseq) {
        next if $attr eq '/';
        $self->{rewrite_html} .= sprintf ' %s="%s"',
                                    $attr,
                                    #_escape($attrs->{$attr}),
                                    $attrs->{$attr};
    }

    $self->{rewrite_html} .= ' /' if $attrs->{'/'};
    $self->{rewrite_html} .= '>';
}

sub _default {
    my ($self, $tagname, $attrs, $text) = @_;
    $self->{rewrite_html} .= $text;
}

1;

