use inc::Module::Install;

all_from 'lib/Foo.pm';

debian;

WriteAll;
