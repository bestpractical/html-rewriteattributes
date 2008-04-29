#!/usr/bin/env perl
use strict;
use warnings;
use HTML::RewriteAttributes::Links;
use Test::More tests => 1;

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

my $rewrote = HTML::RewriteAttributes::Links->rewrite($html, "http://cpan.org");

is($rewrote, << "END", "rewrote the html correctly");
<html>
    <body>
        <img src="http://cpan.org/moose.jpg" />
        <img src="http://example.com/nethack.png">
        <p align="justified" style="color: red">
            hooray
        </p>
    </body>
</html>
END

