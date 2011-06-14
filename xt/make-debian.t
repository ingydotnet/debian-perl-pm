use Test::More tests => 1;

use xt::Test;

my $lib;
use lib do { $lib = abs_path 'lib' };

chdir 'xt/Foo' or die;

run "make purge", 1;
run "perl Makefile.PL";

$ENV{PERL5LIB} = $lib;

run "make debian";

pass;
