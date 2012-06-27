package BuzzSaw::Filter::Auth; # -*-perl-*-
use strict;
use warnings;

our $VERSION = '@LCFG_VERSION@';

# $Id:$
# $Source:$
# $Revision:$
# $HeadURL:$
# $Date:$

use Moose;

with 'BuzzSaw::Filter';

sub check {
    my ( $self, $event ) = @_;

    my @tags = qw(auth);

    my $accept = 0;
    if ( exists $event->{program} ) {
        if ( $event->{program} eq 'gnome-screensaver-dialog' ) {
            $accept = 1;
        } elsif ( $event->{program} eq 'unix_chkpwd' ) {
            $accept = 1;

            if ( $event->{message} =~ m/^(?:could not obtain user info|password check failed for user) \(([^)]+)\)/ ) { 
                $event->{userid} = $1;
                push @tags, 'pam_error';
            }                

        }
    }

    return ( $accept, @tags );
}

1;
__END__

=head1 NAME

BuzzSaw::Filter::Kernel - 

=head1 VERSION

This documentation refers to BuzzSaw::Filter::Kernel version @LCFG_VERSION@

=head1 USAGE

=head1 DESCRIPTION

=head1 REQUIRED ARGUMENTS

=head1 OPTIONS

=over 4

=item

=back

=head1 CONFIGURATION

=head1 EXIT STATUS

=head1 INCOMPATIBILITIES

=head1 DIAGNOSTICS

=head1 DEPENDENCIES

This application requires

=head1 SEE ALSO

=head1 PLATFORMS

This is the list of platforms on which we have tested this
software. We expect this software to work on any Unix-like platform
which is supported by Perl.

@LCFG_PLATFORMS@

=head1 BUGS AND LIMITATIONS

Please report any bugs or problems (or praise!) to bugs@lcfg.org,
feedback and patches are also always very welcome.

=head1 AUTHOR

@LCFG_AUTHOR@

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2012 University of Edinburgh. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the terms of the GPL, version 2 or later.

=cut
