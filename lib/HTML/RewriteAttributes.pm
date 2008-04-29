#!/usr/bin/env perl
package HTML::RewriteAttributes;
use strict;
use warnings;
use base 'HTML::Parser';
use Carp 'croak';
use HTML::Entities 'encode_entities';

our $VERSION = '0.01';

sub new {
    my $class = shift;
    return $class->SUPER::new(
        start_h   => [ '_start_tag', "self,tagname,attr,attrseq,text" ],
        default_h => [ '_default',   "self,tagname,attr,text"         ],
    );
}

sub rewrite {
    my $self = shift;
    $self = $self->new if !ref($self);
    $self->_rewrite(@_);
}

sub _rewrite {
    my $self = shift;
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

sub _should_rewrite { 1 }

sub _start_tag {
    my ($self, $tag, $attrs, $attrseq, $text) = @_;

    $self->{rewrite_html} .= "<$tag";

    for my $attr (@$attrseq) {
        next if $attr eq '/';

        if ($self->_should_rewrite($tag, $attr)) {
            $attrs->{$attr} = $self->_invoke_callback($tag, $attr, $attrs->{$attr});
            next if !defined($attrs->{$attr});
        }

        $self->{rewrite_html} .= sprintf ' %s="%s"',
                                    $attr,
                                    encode_entities($attrs->{$attr});
    }

    $self->{rewrite_html} .= ' /' if $attrs->{'/'};
    $self->{rewrite_html} .= '>';
}

sub _default {
    my ($self, $tag, $attrs, $text) = @_;
    $self->{rewrite_html} .= $text;
}

sub _invoke_callback {
    my $self = shift;
    my ($tag, $attr, $value) = @_;

    return $self->{rewrite_callback}->($tag, $attr, $value);
}

=head1 NAME

HTML::RewriteAttributes - concise attribute rewriting

=head1 SYNOPSIS

    use HTML::RewriteAttributes;
    $html = HTML::RewriteAttributes->rewrite($html, sub {
        my ($tag, $attr, $value) = @_;

        # delete any attribute that mentions..
        return if $value =~ /COBOL/i;

        $value =~ s/\brocks\b/rules/g;
        return $value;
    });

    use HTML::RewriteAttributes::Resources;
    $html = HTML::RewriteAttributes::Resources->rewrite($html, sub {
        my $uri = shift;
        my $content = fetch_from_mason($uri);
        my $cid = generate_cid_from($content);
        $mime->attach($cid => content);
        return "cid:$cid";
    });

    use HTML::RewriteAttributes::Links;
    $html = HTML::RewriteAttributes::Links->rewrite($html, "http://search.cpan.org");

    HTML::RewriteAttributes::Links->rewrite($html, sub {
        my ($tag, $attr, $value) = @_;
        push @links, $value;
        $value;
    });

=cut

1;

