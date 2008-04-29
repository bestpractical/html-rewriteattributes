#!/usr/bin/env perl
package HTML::RewriteAttributes::Resources;
use strict;
use warnings;
use base 'HTML::RewriteAttributes';

my %rewritable_attrs = (
    bgsound => { src        => 1 },
    body    => { background => 1 },
    img     => { src        => 1 },
    input   => { src        => 1 },
    table   => { background => 1 },
    td      => { background => 1 },
    th      => { background => 1 },
    tr      => { background => 1 },
);

sub _rewrite {
    my $self = shift;
    my $html = shift;
    my $cb   = shift;
    my %args = @_;

    $self->{rewrite_inline_css_cb} = $args{inline_css};
    $self->{rewrite_inline_imports} = $args{inline_imports};
    $self->{rewrite_inline_imports_seen} = {};

    $self->SUPER::_rewrite($html, $cb);
}

sub _should_rewrite {
    my ($self, $tag, $attr) = @_;

    return ( $rewritable_attrs{$tag} || {} )->{$attr};
}

sub _invoke_callback {
    my $self = shift;
    my ($tag, $attr, $value) = @_;

    return $self->{rewrite_callback}->($value, tag => $tag, attr => $attr, rewriter => $self);
}

sub _start_tag {
    my $self = shift;
    my ($tag, $attr, $attrseq, $text) = @_;

    if ($self->{rewrite_inline_css_cb}) {
        if ($tag eq 'link' && $attr->{type} eq 'text/css') {
            my $content = $self->_import($attr->{href});
            if (defined $content) {
                $content = $self->_handle_imports($content);
                $self->{rewrite_html} .= "\n<style type=\"text/css\">\n<!--\n$content\n-->\n</style>\n";
                return;
            }
        }
        if ($tag eq 'style' && $attr->{type} eq 'text/css') {
            $self->{rewrite_look_for_style} = 1;
        }
    }

    $self->SUPER::_start_tag(@_);
}

sub _default {
    my ($self, $tag, $attrs, $text) = @_;
    if (delete $self->{rewrite_look_for_style}) {
        $text = $self->_handle_imports($text);
    }

    $self->SUPER::_default($tag, $attrs, $text);
}

sub _handle_imports {
    my $self    = shift;
    my $content = shift;
    return $content if !$self->{rewrite_inline_imports};

    # repeat until we get no substitutions
    1 while $content =~ s{\@import\s*"([^"]+)"\s*;}{ $self->_import($1) }eg;

    return $content;
}

sub _import {
    my $self = shift;
    my $uri  = shift;

    return '' if $self->{rewrite_inline_imports_seen}{$uri}++;

    return $self->{rewrite_inline_css_cb}->($uri);
}

1;

