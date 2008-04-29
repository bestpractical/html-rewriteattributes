#!/usr/bin/env perl
package HTML::RewriteAttributes::Links;
use strict;
use warnings;
use base 'HTML::RewriteAttributes';
use HTML::Tagset ();
use URI;

my %rewritable_attrs;

for my $tag (keys %HTML::Tagset::linkElements) {
    for my $attr (@{ $HTML::Tagset::linkElements{$tag} }) {
        $rewritable_attrs{$tag}{$attr} = 1;
    }
}

sub _should_rewrite {
    my ($self, $tag, $attr) = @_;

    return ( $rewritable_attrs{$tag} || {} )->{$attr};
}

sub _rewrite {
    my ($self, $html, $arg) = @_;

    if (!ref($arg)) {
        $self->{rewrite_link_base} = $arg;

        $arg = sub {
            my ($tag, $attr, $value) = @_;
            my $uri = URI->new($value);

            $uri = $uri->abs($self->{rewrite_link_base})
                unless defined $uri->scheme;

            return $uri->as_string;
        };
    }

    $self->SUPER::_rewrite($html, $arg);
}

# if we see a base tag, steal its href for future link resolution
sub _start_tag {
    my $self = shift;
    my ($tag, $attr, $attrseq, $text) = @_;

    if ($tag eq 'base' && defined $attr->{href}) {
        $self->{rewrite_link_base} = $attr->{href};
    }

    $self->SUPER::_start_tag(@_);
}

1;

