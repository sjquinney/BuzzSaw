package BuzzSaw::Catalogue; # -*-perl-*-
use strict;
use warnings;

our $VERSION = '@LCFG_VERSION@';

# $Id:$
# $Source:$
# $Revision:$
# $HeadURL:$
# $Date:$

use Moose::Role;

requires 'register_event', 'check_event_seen',
         'register_log', 'check_log_seen';

no Moose::Role;

1;
__END__

=head1 NAME

BuzzSaw::Catalogue - 

=head1 VERSION

This documentation refers to BuzzSaw::Catalogue version @LCFG_VERSION@

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
