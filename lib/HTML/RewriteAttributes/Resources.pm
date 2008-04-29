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

sub _should_rewrite {
    my ($self, $tag, $attr) = @_;

    return ( $rewritable_attrs{$tag} || {} )->{$attr};
}

sub _invoke_callback {
    my $self = shift;
    my ($tag, $attr, $value) = @_;

    return $self->{rewrite_callback}->($value, tag => $tag, attr => $attr, rewriter => $self);
}

1;

