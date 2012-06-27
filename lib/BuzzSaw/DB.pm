package BuzzSaw::DB; # -*-perl-*-
use strict;
use warnings;

our $VERSION = '@LCFG_VERSION@';

# $Id:$
# $Source:$
# $Revision:$
# $HeadURL:$
# $Date:$

use BuzzSaw::DB::Schema;

use Moose;
use MooseX::Types::Moose qw(Int Str);

with 'BuzzSaw::Catalogue';

has 'name' => (
    is       => 'ro',
    isa      => Str,
    required => 1,
    default  => 'buzzsaw',
    documentation => 'The name of the database',
);

has 'host' => (
    is        => 'ro',
    isa       => Str,
    predicate => 'has_host',
    documentation => 'The host name of the database server',
);

has 'port' => (
    is        => 'ro',
    isa       => Int,
    predicate => 'has_port',
    documentation => 'The port on which the database server is listening',
);

has 'user' => (
    is        => 'ro',
    isa       => 'Maybe[Str]',
    default   => q{},
    documentation => 'The user name with which to connect to the database',
);

has 'pass' => (
    is        => 'ro',
    isa       => 'Maybe[Str]',
    default   => q{},
    documentation => 'The password with which to connect to the database',
);

has 'schema' => (
    is      => 'ro',
    isa     => 'BuzzSaw::DB::Schema',
    lazy    => 1,
    builder => '_connect',
    documentation => 'The DBIx::Class schema object',
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub build_dsn {
    my ($self) = @_;

    my $dsn = 'dbi:Pg:dbname=' . $self->name;
    if ( $self->has_host ) {
        $dsn = $dsn . ';host=' . $self->host;
    }
    if ( $self->has_port ) {
        $dsn = $dsn . ';port=' . $self->port;
    }

    return $dsn;
}

sub _connect {
    my ($self) = @_;

    my $dsn  = $self->build_dsn;
    my $user = $self->user;
    my $pass = $self->pass;

    my %attrs = (
        AutoCommit => 1,
        RaiseError => 1
    );

    my $schema
        = BuzzSaw::DB::Schema->connect( $dsn, $user, $pass, \%attrs );

    return $schema;
}

sub register_event {
    my ( $self, $event ) = @_;

    my $schema = $self->schema;
    my $event_rs = $schema->resultset('Event');
    my $event_source = $event_rs->result_source;

    # Cannot just pass in the event hash as it may contain keys which
    # do not map onto column names.

    my %event_in_db;
    for my $column ( $event_source->columns ) {
        if ( exists $event->{$column} && defined $event->{$column} ) {
            $event_in_db{$column} = $event->{$column};
        }
    }

    if ( exists $event->{tags} && defined $event->{tags} ) {
        $event_in_db{tags} = [ map {  { name => $_ } } @{ $event->{tags} } ];
    }

    my $new_event = $event_rs->new( \%event_in_db );
    $new_event->insert;

    return;
}

sub check_event_seen {
    my ( $self, $event ) = @_;

    my $digest = $event->{digest};

    my $schema = $self->schema;
    my $entry_rs = $schema->resultset('Event')->search( { digest => $digest } );
    my $count = $entry_rs->count;

    return $count > 0 ? 1 : 0;
}

sub register_log {
    my ( $self, $file, $digest ) = @_;

   my $schema = $self->schema;

    my $new_log = $schema->resultset('Log')->new( { digest => $digest,
                                                    name   => $file } );
    $new_log->insert;

    return;
}

sub check_log_seen {
    my ( $self, $file, $digest ) = @_;

    my $schema = $self->schema;
    my $entry_rs = $schema->resultset('Log')->search( { digest => $digest } );
    my $count = $entry_rs->count;

    return $count > 0 ? 1 : 0;
}

1;
__END__

