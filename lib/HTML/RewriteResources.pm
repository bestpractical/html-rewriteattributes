#!/usr/bin/env perl
package HTML::RewriteResources;
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
    my $self = shift;
    my $tag  = shift;
    my $attr = shift;

    return ( $rewritable_attrs{$tag} || {} )->{$attr};
}

1;

