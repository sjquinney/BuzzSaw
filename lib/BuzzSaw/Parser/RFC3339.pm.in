package BuzzSaw::Parser::RFC3339; # -*-perl-*-
use strict;
use warnings;

our $VERSION = '@LCFG_VERSION@';

use Moose;

with 'BuzzSaw::Parser';

# $Id:$
# $Source:$
# $Revision:$
# $HeadURL:$
# $Date:$

no Moose;
__PACKAGE__->meta->make_immutable;

sub parse_line {
    my ( $self, $line ) = @_;

    # These field names match those used by the DateTime module

    my %results;
    if ( $line =~ m{^
                      (?<year>\d{4})                     # year
                      -
                      (?<month>\d{2})                    # month
                      -
                      (?<day>\d{2})                      # day
                      T
                      (?<hour>\d{2})                     # hour
                      :
                      (?<minute>\d{2})                   # minute
                      :
                      (?<second>\d{2})                   # second
                      (?<nanosecond>\.\d+)?              # nanosecond
                      (?<time_zone>(?:\+|\-)\d{2}:\d{2}) # time_zone
                      \s+
                      (?<hostname>\S+)                   # hostname
                      \s+
                      (?<message>.+)                     # message
                     $}xo ) {
        %results = %+;

        if ( defined $results{nanosecond} ) {
            $results{nanosecond} *= 1000000000;
        } else {
            $results{nanosecond} = 0;
        }

        # Attempt to acquire more information from the message

        if ( $results{message} =~
             m{^
               (?<program>[^\s:\[]+)       # program
               (?:\[(?<pid>\d+)\])?        # pid
               :
               \s+
               (?<message>.+)              # shortened message
               $}xo ) {
            %results = ( %results, %+ );
        }
 
    } else {
        die "Failed to parse line: $line\n";
    }

    return %results;
}

1;
__END__

=head1 NAME

BuzzSaw::Parser::RFC3339 - 

=head1 VERSION

This documentation refers to BuzzSaw::Parser::RFC3339 version @LCFG_VERSION@

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
