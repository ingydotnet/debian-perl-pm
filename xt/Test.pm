package xt::Test;
use strict;
use base 'Exporter';
use Cwd qw'cwd abs_path';

our @EXPORT = qw(run cmd abs_path);

sub import {
    strict->import;
    warnings->import;
    goto &Exporter::import;
}

sub run {
    my $cmd = shift;
    warn ">> $cmd\n";
    system($cmd) == 0 or @_ or die "Error: '$cmd' failed\n";
}

1;
