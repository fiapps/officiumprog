#!/usr/bin/perl -w

use Test::More tests => 8;

use_ok('HTML::FormatText');
use_ok('Test::HTML::Lint');
use_ok('HTML::Lint::Error');

require_ok('t/TestOfficium.pl');

$off1 = Test::Officium->new();
isa_ok($off1, Test::Officium);

TODO: {
local $TODO = 'Pofficium.pl does not produce clean HTML yet.';
html_ok($off1->html(), 'Validate HTML for the default office');
}

like($off1->text(), qr/\bDeus\b/, '"Deus" is present in the default office');
like($off1->text(), qr/\bAlleluia\b/, '"Alleluia" is present in the default office');
