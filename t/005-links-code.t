#!/usr/bin/env perl
use strict;
use warnings;
use HTML::RewriteAttributes::Links;
use Test::More tests => 2;

my $html = << "END";
<html>
    <body>
        <img src="moose.jpg" />
        <img src="http://example.com/nethack.png">
        <p align="justified" style="color: red">
            hooray
        </p>
    </body>
</html>
END

my @seen;

my $rewrote = HTML::RewriteAttributes::Links->rewrite($html, sub {
    my ($tag, $attr, $value) = @_;

    push @seen, [$tag, $attr, $value];

    uc $value;
});

is_deeply(\@seen, [
    [img => src => "moose.jpg"],
    [img => src => "http://example.com/nethack.png"],
]);

is($rewrote, << "END", "rewrote the html correctly");
<html>
    <body>
        <img src="MOOSE.JPG" />
        <img src="HTTP://EXAMPLE.COM/NETHACK.PNG">
        <p align="justified" style="color: red">
            hooray
        </p>
    </body>
</html>
END


