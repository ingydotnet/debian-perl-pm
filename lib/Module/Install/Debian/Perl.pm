##
# name:      Module::Install::Debian::Perl
# abstract:  Module::Install Support for Debian::Perl
# author:    Ingy döt Net
# license:   perl
# copyright: 2011
# see:
# - Debian::Perl
# - Module::Install

package Module::Install::Debian::Perl;
use 5.008003;
use strict;
use warnings;
use base 'Module::Install::Base';

our $VERSION = '0.02';
our $AUTHOR_ONLY = 1;

sub debian {
    my ($self) = @_;
    return unless $self->is_admin;
    $self->postamble(<<'...');
debian::
	$(PERL) -Ilib -MDebian::Perl -e "Debian::Perl->make_debian"

release::
	$(PERL) -Ilib -MDebian::Perl -e "Debian::Perl->make_release"
...
}

1;

=head1 SYNOPSIS

In your Makefile.PL;

    use inc::Module::Install;
    ...
    debian;
    ...

From the command line:

    > perl Makefile.PL
    > make debian
    > make release
