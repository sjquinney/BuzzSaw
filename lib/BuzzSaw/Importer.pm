package BuzzSaw::Importer; # -*-perl-*-
use strict;
use warnings;

our $VERSION = '@LCFG_VERSION@';

# $Id:$
# $Source:$
# $Revision:$
# $HeadURL:$
# $Date:$

use DateTime;

use Moose;
use MooseX::Types::Moose qw(Bool);

has 'sources' => (
    traits   => ['Array'],
    isa      => 'ArrayRef[BuzzSaw::DataSource]',
    is       => 'ro',
    required => 1,
    handles  => {
        'list_sources' => 'elements',
    },
);

has 'filters' => (
    traits   => ['Array'],
    isa      => 'ArrayRef[BuzzSaw::Filter]',
    is       => 'ro',
    required => 1,
    handles  => {
        'list_filters' => 'elements',
    },
);

has 'catalogue' => (
    does     => 'BuzzSaw::Catalogue',
    is       => 'ro',
    required => 1,
);

has 'readall' => (
    isa     => Bool,
    is      => 'ro',
    default => 0,
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub import_events {
    my ($self) = @_;

    my $catalogue = $self->catalogue;

    my @filters = $self->list_filters;

    # If there are no filters we will accept ALL entries

    my $accept_default = scalar @filters > 0 ? 0 : 1;

    my $examined_count = 0;
    my $accepted_count = 0;

    for my $source ( $self->list_sources ) {

        $source->readall(1) if $self->readall;
        $source->catalogue($catalogue);

        $source->reset();

        while ( defined ( my $entry = $source->next_entry) ) {
            $examined_count++;

            # ignore empty entries
            if ( $entry =~ m/^\s*$/ ) {
                next;
            }

            my $digest = Digest::SHA::sha512_base64($entry);

            my %event = ( raw => $entry, digest => $digest );

            my $seen = $self->catalogue->check_event_seen(\%event);

            if ($seen) {
                next;
            }

            # Parsing

            my %results = $source->parser->parse_line($entry);

            %event = ( %results, %event );

            # Filtering

            my $accept = $accept_default;

            my %all_tags;
            for my $filter (@filters) {
                my ( $result, @tags ) = $filter->check(\%event);
                if ($result) {
                    $accept = 1;
                    for my $tag (@tags) {
                        $all_tags{$tag} = 1;
                    }
                }
            }

            $event{tags} = [keys %all_tags];

            # Registering

            if ($accept) {
                $accepted_count++;
                my %date;
                for my $key (qw/year month day hour minute second nanosecond time_zone/) {
                    $date{$key} = $event{$key};
                }
                $event{logtime} = DateTime->new( %date );

                $catalogue->register_event(\%event);
            }

        }
    }

    print "Examined $examined_count entries, accepted $accepted_count\n";
}

1;
__END__

=head1 NAME

BuzzSaw::Importer - 

=head1 VERSION

This documentation refers to BuzzSaw::Importer version @LCFG_VERSION@

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
