package BuzzSaw::DataSource::Files; # -*-perl-*-
use strict;
use warnings;

our $VERSION = '@LCFG_VERSION@';

# $Id:$
# $Source:$
# $Revision:$
# $HeadURL:$
# $Date:$

use Cwd ();
use Digest::SHA ();
use File::Find::Rule ();
use IO::File ();
use List::MoreUtils ();

use Moose;
use MooseX::Types::Moose qw(Bool);
use Moose::Meta::Attribute::Native::Trait::Array;

with 'BuzzSaw::DataSource';

has 'directories' => (
    traits   => ['Array'],
    isa      => 'ArrayRef[Str]',
    is       => 'ro',
    required => 1,
    default  => sub { [ q{.} ] },
    handles  => {
        list_directories  => 'elements',
        count_directories => 'count',
    },
);

has 'names' => (
    traits   => ['Array'],
    isa      => 'ArrayRef[Str]',
    is       => 'ro',
    required => 1,
    default  => sub { [] },
    handles  => {
        list_names  => 'elements',
        count_names => 'count',
    },
);

has 'recursive' => (
    isa     => Bool,
    is      => 'ro',
    default => 1,
);

has 'files' => (
    traits   => ['Array'],
    isa      => 'ArrayRef[Str]',
    is       => 'ro',
    writer   => '_set_files',
    builder  => '_find_files',
    lazy     => 1,
    handles  => {
        list_files   => 'elements',
        count_files  => 'count',
        get_filename => 'get',
    },
);

has '_current_fileidx' => (
    isa      => 'Maybe[Int]',
    is       => 'rw',
    init_arg => undef,
    default  => sub { -1 },
);

has '_current_digest' => (
    isa      => 'Maybe[Str]',
    is       => 'rw',
    init_arg => undef,
);

has '_current_fh' => (
    isa      => 'Maybe[FileHandle]',
    is       => 'rw',
    init_arg => undef,
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub BUILD {
    my ($self) = @_;

    if ( $self->count_files == 0 && $self->count_names == 0 ) {
        die "You must specify either a set of files or a set of names to find\n";
    }

    return;
}

sub _find_files {
    my ($self) = @_;

    my $finder = File::Find::Rule->new();
    $finder->file;     # Only interested in files
    $finder->nonempty; # No point examining empty files

    my @rules = map { File::Find::Rule->name( $_ ) } $self->list_names;

    $finder->any(@rules);

    if ( !$self->recursive ) {
        $finder->maxdepth(1);
    }

    my $iter = $finder->start($self->list_directories);

    my @files;
    while ( defined( my $file = $iter->match ) ) {
        if ( $file !~ m{^/} ) {
            $file = Cwd::abs_path($file);
        }

        push @files, $file;
    }

    return \@files;
}

sub reset {
    my ($self) = @_;

    $self->_current_fileidx(-1);
    $self->_current_fh(undef);

    return $self->_set_files( $self->_find_files );
}

sub next_entry {
    my ($self) = @_;

    my ( $entry, $id );

    my $seen = 1;

    my $fh = $self->_current_fh // $self->_next_fh;

    # Ensure we do not attempt to get a line from an empty file
    while ( defined $fh && $fh->eof ) {
        $fh = $self->_next_fh;
    }

    if ( !defined $fh ) {
        return;
    }

    chomp ( my $line = $fh->getline );

    return $line;
}

sub _next_fh {
    my ($self) = @_;

    my $current_fh = $self->_current_fh;
    if ( defined $current_fh ) {
        my $current_file   = $self->_current_filename;
        my $current_digest = $self->_current_digest;
        $self->catalogue->register_log( $current_file, $current_digest );
        $current_fh->close;
    }

    my $file = $self->_next_filename;

    # This ensures that if a file has disappeared or become
    # unopenable in anyway we just move on. Much better to do this
    # than fail out right in the middle of a long run.

    my $new_fh;
    while ( defined $file && !defined $new_fh ) {
        warn "Opening $file\n";

        $new_fh = eval {

            my $fh;
            if ( $file =~ m/\.gz$/ ) {
                require IO::Uncompress::Gunzip;
                $fh = IO::Uncompress::Gunzip->new($file)
                    or die "Could not open $file: $IO::Uncompress::Gunzip::GunzipError\n";
            } elsif ( $file =~ m/\.bz2$/ ) {
                require IO::Uncompress::Bunzip2;
                $fh = IO::Uncompress::Bunzip2->new($file)
                    or die "Could not open $file: $IO::Uncompress::Bunzip2::Bunzip2Error\n";
            } else {
                warn "plain text file\n";
                $fh = IO::File->new( $file, 'r' )
                    or die "Could not open $file: $!\n";
            }
            return $fh;
        };

        if ( $@ || !defined $new_fh ) {
            warn "$@" if $@;
            # just move onto the next available file
            $file = $self->_next_filename;
        }

    }

    $self->_current_fh($new_fh);

    return $new_fh;
}

sub _current_filename {
    my ($self) = @_;

    my $filename;
    my $cur_fileidx = $self->_current_fileidx;
    if ( defined $cur_fileidx && $cur_fileidx >= 0 ) {
        $filename = $self->get_filename($cur_fileidx);
    }

    return $filename;
}

sub _next_filename {
    my ($self) = @_;

    my $file_count = $self->count_files;

    my $next_filename;

    my $seen = 1;
    while ($seen) {
        my $cur_fileidx = $self->_current_fileidx;
        if ( defined $cur_fileidx ) { 
            if ( $cur_fileidx + 1 < $file_count ) {
                $cur_fileidx  = $cur_fileidx + 1;
            } else {
                $cur_fileidx = undef;
            }
            $self->_current_fileidx($cur_fileidx);
        }
        my $new_filename = $self->_current_filename;

        if ( !defined $new_filename ) {
            last;
        }

        if ( !-e $new_filename ) {
            warn "$new_filename has disappeared\n";
            next;
        }

        my $sha = Digest::SHA->new(512);
        $sha->addfile($new_filename);
        my $file_digest = $sha->b64digest;

        # check if we have previously seen the new file
        if ( $self->readall ) {
            $seen = 0;
        } else {
            $seen = $self->catalogue->check_log_seen( $new_filename, $file_digest );
        }

        if ( !$seen ) {
            $next_filename = $new_filename;
            $self->_current_digest($file_digest);
        } else {
            warn "Already seen $new_filename\n";
        }
    }

    return $next_filename;
}

1;
__END__

=head1 NAME

BuzzSaw::DataSource - 

=head1 VERSION

This documentation refers to BuzzSaw::DataSource version @LCFG_VERSION@

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
