#!/usr/bin/env perl
use strict;
use warnings;
use HTML::RewriteResources;
use Test::More tests => 4;

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

my $rewrote = HTML::RewriteResources->rewrite($html, sub {
    my $uri = shift;
    $seen{$uri}++;
    return uc $uri;
});

is(keys %seen, 2, "saw two resources");
is($seen{"moose.jpg"}, 1, "saw moose.jpg once");
is($seen{"http://example.com/nethack.png"}, 1, "saw http://example.com/nethack.png once");

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

