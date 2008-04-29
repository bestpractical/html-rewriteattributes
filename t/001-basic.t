#!/usr/bin/env perl
use strict;
use warnings;
use HTML::RewriteAttributes::Resources;
use Test::More tests => 6;

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

my %seen_uri;
my %seen_tag;

my $rewrote = HTML::RewriteAttributes::Resources->rewrite($html, sub {
    my $uri = shift;
    my $tag = shift;

    $seen_uri{$uri}++;
    $seen_tag{$tag}++;

    return uc $uri;
});

is(keys %seen_uri, 2, "saw two resources");
is($seen_uri{"moose.jpg"}, 1, "saw moose.jpg once");
is($seen_uri{"http://example.com/nethack.png"}, 1, "saw http://example.com/nethack.png once");

is(keys %seen_tag, 1, "saw two tag");
is($seen_tag{"img"}, 2, "saw img twice");

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

