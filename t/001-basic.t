#!/usr/bin/env perl
use strict;
use warnings;
use HTML::RewriteAttributes::Resources;
use Test::More tests => 8;

my $html = << "END";
<html>
    <body>
        <img src="moose.jpg" />
        <img src="http://example.com/nethack.png">
        <p align="justified">
            hooray
        </p>
    </body>
</html>
END

my %seen;

my $rewrote = HTML::RewriteAttributes::Resources->rewrite($html, sub {
    my $uri  = shift;
    my %args = @_;

    $seen{uri}{$uri}++;
    $seen{tag}{$args{tag}}++;
    $seen{attr}{$args{attr}}++;

    return uc $uri;
});

is(keys %{ $seen{uri} }, 2, "saw two resources");
is($seen{uri}{"moose.jpg"}, 1, "saw moose.jpg once");
is($seen{uri}{"http://example.com/nethack.png"}, 1, "saw http://example.com/nethack.png once");

is(keys %{ $seen{tag} }, 1, "saw one tag");
is($seen{tag}{img}, 2, "saw img twice");

is(keys %{ $seen{attr} }, 1, "saw one attr");
is($seen{attr}{src}, 2, "saw src twice");

is($rewrote, << "END", "rewrote the html correctly");
<html>
    <body>
        <img src="MOOSE.JPG" />
        <img src="HTTP://EXAMPLE.COM/NETHACK.PNG">
        <p align="justified">
            hooray
        </p>
    </body>
</html>
END

