##
# name:      Debian::Perl
# abstract:  CPAN Author's Debian Packaging Toolset
# author:    Ingy döt Net <ingy@cpan.org>
# license:   perl
# copyright: 2011
# see:
# - DhMakePerl
# - Module::Install::Debian::Perl

use 5.008003;
package Debian::Perl;
use Mouse 0.93;

our $VERSION = '0.02';

use Debian::Perl::Config;
use MouseX::App::Cmd 0.08;
use DhMakePerl 0.71 ();
use Capture::Tiny 0.10 'capture';
use CPAN::Meta::YAML 0.003 ();

use XXX;

has perl => ( is => 'ro', default => $^X );
has conf => (
    is => 'ro',
    lazy => 1,
    builder => sub { Debian::Perl::Config->new() },
);
has module_layout => ( is => 'ro', lazy => 1, builder => 'module_layout__' );
has meta => ( is => 'ro', lazy => 1, builder => 'meta__' );

sub run;

#-----------------------------------------------------------------------------
# Top level driver functions
#-----------------------------------------------------------------------------
sub build {
    my $self = shift;
    eval {
        $self->start_msg;
        $self->assert_module_dir;
        $self->prep_module_dir;
        $self->make_dist_dir;
        $self->dh_make_perl;
        $self->debuild;
        $self->lintian;
        $self->pbuilder;
    };
    $self->final_report($@);
}

sub config {
    run "rm -fr *.deb";
}

sub release {
    my $self = shift;
    die "'debian-perl release' not yet implemented";
}

sub clean {
    run "rm *.deb";
}

#-----------------------------------------------------------------------------
# Support functions
#-----------------------------------------------------------------------------

sub run {
    my $cmd = shift;
    my %options = map {($_, 1)} @_;
    print ">> $cmd\n";
    my $error = 0;
    my $output = Capture::Tiny::capture_merged {
        system(@_) == 0 or $error = 1;
    };
    die $output if $error and not $options{ignore};
}

sub start_msg {
    my $self = shift;
    print "\nBuilding your Debian Package...\n";
}

sub assert_module_dir {
    my $self = shift;
    die "This doesn't look like a Perl module source directory"
        unless $self->module_layout;
}

sub prep_module_dir {
    my $self = shift;
    my $layout = $self->module_layout or die;
    my $method = "prep_${layout}_dir";
    $self->$method;
    die "Need META.yml or META.json"
        unless $self->meta;
}

sub prep_makefile_dir {
    my $self = shift;
    run "perl Makefile.PL"
        unless not -e 'Makefile';
}

sub prep_build_dir {
    my $self = shift;
    # TODO
}

sub prep_dzil_dir {
    my $self = shift;
    # TODO
    run "dzil dist";
}

sub make_dist_dir {
    my $self = shift;
}

sub dh_make_perl {
    my $self = shift;
    capture {
        DhMakePerl->run;
    };
}

sub debuild {
    my $self = shift;
}

sub lintian {
    my $self = shift;
}

sub pbuilder {
    my $self = shift;
}

sub final_report {
    my $self = shift;
    my $error = shift;
    $error =~ s/^/    /gm;
    die <<"..." if $error;
An unexpected error occurred:

$error
...
}

#-----------------------------------------------------------------------------
# Top level functions for perl one-liners, like in Makefile.
#-----------------------------------------------------------------------------
sub module_layout__ {
    my $self = shift;
    if (-e 'Makefile.PL') {
        if (-e 'inc' and not -e 'inc/.author') {
            return '';
        }
        return 'makefile';
    }
    elsif (-e 'Build.PL') {
        return 'build';
    }
    elsif (-e 'dist.ini') {
        return 'dzil';
    }
    return '';
}

#-----------------------------------------------------------------------------
# Top level functions for perl one-liners, like in Makefile.
#-----------------------------------------------------------------------------
sub make_debian {
    my $class = shift;
    $class->new->build;
}

sub make_release {
    my $class = shift;
    $class->new->release;
}

1;

=head1 SYNOPSIS

From the command line:

    > debian-perl build
    > debian-perl release

From a Perl module directory:

    > Perl Makefile.PL
    > make debian
    > make release

=head1 DESCRIPTION

Debian::Perl is a set of tools that encourages CPAN authors to become the
Debian maintainers for their work, or to at least provide the necessary
structure for downstream (Debian) maintainers. It tries to make prepping
for Debian a very simple and discoverable process.

=head1 RATIONALE

If you are a Perl CPAN module author, you probably know quite a bit about
Perl, CPAN and modules. You probably know about Debian Linux. There's even a
decent chance you've used it. However, there's only a very slim chance that
you maintain Debian packages for your modules.

Let's assume that this at least vaguely describes you. If someone told you
that you could flip a switch, and then every time you released a module to
CPAN, it went to Debian (perfectly packaged to their standards), you'd
probably flip that switch.

This module aspires to be that switch. It wants you to be a Debian Maintainer
for free. You may end up becoming a full fledged Debian guru one day, but for
now you just want to see your code available to a whole new world, without
having to know the details. As long as this switch doesn't tell you
otherwise, you know that you did the all right things.

This module is just a helping hand that automates all the standard best
practices for you. It bends over backwards to help you get that module to
Debian without having to know any more than is expected of a busy Perl module
author, like yourself.

Specifically it uses things like C<dh-make-perl>, C<debuild>, C<pbuilder> and
C<lintian>. If you've never heard of these things, that's ok. Until this week,
neither did I. They all do a lot of work, and they aren't that hard to use,
but the learning curve is quite high. As soon as Debian::Perl is stable and
shipping all my CPAN modules to Debian, I plan to forget about them as quickly
as possible. :)

=head1 USAGE

There are two ways to use this module. There is a command line tool called
C<debian-perl> that you can use to prepare, build, test and release Debian
packages from your Perl module. There is also a Module::Install plugin that
allows you to issue C<make debian> commands.

To get your module to the goal, of Debian happiness, you will often need to supply extra 

=head2 Environment

Using these commands assumes that you are cd'd into the source directory of
your module. It also assumes that you use a Makefile.PL
(L<ExtUtils::MakeMaker>, L<Module::Install> or L<Module::Package), a
L<Module::Build>, or a L<Dist::Zilla> based layout.

When you use the Debian::Perl tool to build and test a Debian package from
your code, everything will happen under your current directory, including the
location of final .deb file.

NOTE: Debian::Perl isn't very useful for applying to other people's modules
from CPAN, because you won't have the original sources that these were created
from. Users of Debian::Perl often need to maintain a number of Debian hints,
and these files don't get packaged into the CPAN distribution packages.

=head2 C<debian-perl> usage

This is the primary command line tool provided by Debian::Perl. Try:

    debian-perl help
    debian-perl config
    debian-perl build
    debian-perl test
    debian-perl clean

Also see L<debian-perl>.

=head2 C<Makefile> usage

If you use L<Module::Install> in your Makefile.PL, you can just add a single line, like this:

    use inc::Module::Install;
    ...
    debian_perl;
    ...
    WriteAll;

Then you will have access to Makefile targets like:

    make debian-config
    make debian-build
    make debian-test
    make debian-upload

and

    make clean

will remove any debian build mess.

See L<Module::Install::Debian::Perl> for more info.

=head2 Debian::Perl Configuration

This module looks for author specified conguration hints in a few places.
First it looks for a a directory called C<./debian/> or C<./package/debian/>.

Under this directory, it looks for a file called C<conf.yaml>. This file is
used for top level configuration instructions. See L<Debian::Perl::Config>.

You can create a new C<./debian/conf.yaml> config file with this command:

    debian-perl config

=head1 PROCESSING

This section describes exactly what happens when you issue C<debian-perl>
commands. It is useful for people who want to understand exactly what
C<debian-perl> is doing without reading its source code.

=head1 IN PROGRESS

More doc coming soon...

=head1 STATUS

This module is brand new and in heavy development. Nothing to see here. Move
along.

=head1 KUDOS

Many thanks to the great folks at Strategic Data for supporting the creation
of this module.

Extra special thanks to Andrew Pam, the resident Debian guru at Strategic
Data, for providing all the right pointers.

Also a nod to Jeremiah Foster whose article in The Perl Review from the Spring
2009 issue, not only pointed me in the right directions, but also convinced me
that the process was still not quite consumable by the masses.

Finally, a big shout out to the Debian Perl team (irc.oftc.org#debian-perl
and debian-perl@lists.debian.org) who are the masters of Perl maintenance for
Debian. In working with them, I have become one of them.
