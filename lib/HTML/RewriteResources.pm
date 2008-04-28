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

sub _start_tag {
    my ($self, $tagname, $attr, $attrseq, $text) = @_;
    $self->{rewrite_html} .= $text;
}

sub _default {
    my ($self, $tagname, $attr, $text) = @_;
    $self->{rewrite_html} .= $text;
}

1;

