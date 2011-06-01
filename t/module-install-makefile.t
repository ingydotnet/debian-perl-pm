use Test::More;

plan skip_all => 'Requires Module::Install'
    unless eval 'require Module::Install; 1';

plan tests => 2;

chdir 't/Foo' or die;
system("$^X Makefile.PL") == 0 or die;
open MF, 'Makefile' or die;
my $makefile = do {local $/; <MF>};
my $ok = ($makefile =~ /^debian::$/m);
ok $ok, "We have Makefile 'debian' target";
if ($ok) {
    system("make purge") == 0 or die;
    pass 'make purge';
}
