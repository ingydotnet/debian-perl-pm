##
# name:      Debian::Perl::Cmd
# abstract:  Command class for Debian::Perl
# author:    Ingy döt Net <ingy@cpan.org>
# license:   perl
# copyright: 2011

use 5.008003;

# Setup command class
package Debian::Perl::Cmd;
use Mouse; extends 'MouseX::App::Cmd';

use constant usage => 'Debian::Perl::Cmd';
use constant text => "Usage: debian-perl command [<options>]\n";
use constant default_command => 'help';

# Base class for commands
package Debian::Perl::Command;
use Mouse; extends 'MouseX::App::Cmd::Command';
use Debian::Perl;

sub command {
    my ($self) = @_;
    ((my $command = ref($self) || $self) =~ s/.*::// or die);
    return $command;
}

sub execute {
    my ($self) = @_;
    my $command = $self->command;
    Debian::Perl->new->$command;
}

sub usage_desc {
    my ($self) = @_;
    my $command = $self->command;
    return "Usage: debian-perl $command";
}

# Semi-brutal hack to suppress the extra -? option I don't care about.
around usage => sub {
    my $orig = shift;
    my $self = shift;
    my $opts = $self->{usage}->{options};
    @$opts = grep { $_->{name} ne 'help' } @$opts;
    return $self->$orig(@_);
};

#------------------------------------------------------------------------------
package Debian::Perl::Cmd::Command::build;
use Mouse; extends 'Debian::Perl::Command';

use constant abstract => 'Build a new debian package from this Perl source';

#------------------------------------------------------------------------------
package Debian::Perl::Cmd::Command::config;
use Mouse; extends 'Debian::Perl::Command';

use constant abstract => 'Write a new debian-perl config file';

#------------------------------------------------------------------------------
package Debian::Perl::Cmd::Command::upload;
use Mouse; extends 'Debian::Perl::Command';

use constant abstract => 'Move your debian-perl package downstream';

#------------------------------------------------------------------------------
package Debian::Perl::Cmd::Command::clean;
use Mouse; extends 'Debian::Perl::Command';

use constant abstract => 'Remove debian-perl build files';

1;

=head1 DESCRIPTION

This module uses C<App::Cmd> to define a nice command line tool,
C<debian-perl>, with all the trimmings.

