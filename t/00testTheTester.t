use Test::More tests => 6;

use_ok(LWP::Simple);
use_ok(URI::Escape);
use_ok(HTML::FormatText);
use_ok(Test::HTML::Lint);

require_ok('t/TestOfficium.pl');

$off = Test::Officium->new();
isa_ok($off, Test::Officium);
