##
# name:      Debian::Perl::Config
# abstract:  Config class for Debian::Perl
# author:    Ingy döt Net <ingy@cpan.org>
# license:   perl
# copyright: 2011

use 5.008003;
package Debian::Perl::Config;
use Mouse;

has config_file => ( is => 'ro', default => sub {+{}} );

sub BUILD {
    my ($self) = @_;
    if (my $file = $self->config_file) {
        my $hash = YAML::XS::LoadFile($file);
        for my $key (keys %$hash) {
            $self->{$key} = $hash->{$key};
        }
    }
}

1;
