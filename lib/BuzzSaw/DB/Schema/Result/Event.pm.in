package BuzzSaw::DB::Schema::Result::Event;
use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

BuzzSaw::DB::Schema::Result::Event

=cut

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);
__PACKAGE__->table('event');

=head1 ACCESSORS

=head2 id

  data_type: integer
  default_value: nextval('event_id_seq'::regclass)
  is_auto_increment: 1
  is_nullable: 0

=head2 raw

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 1000

=head2 digest

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 200

=head2 logtime

  data_type: timestamp with time zone
  default_value: undef
  is_nullable: 0

=head2 hostname

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 100

=head2 message

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 1000

=head2 program

  data_type: character varying
  default_value: undef
  is_nullable: 1
  size: 100

=head2 pid

  data_type: integer
  default_value: undef
  is_nullable: 1

=head2 userid

  data_type: character varying
  default_value: undef
  is_nullable: 1
  size: 20

=cut

__PACKAGE__->add_columns(
  'id',
  {
    data_type         => 'integer',
    default_value     => \q{nextval('event_id_seq'::regclass)},
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  'raw',
  {
    data_type         => 'character varying',
    default_value     => undef,
    is_nullable       => 0,
    size              => 1000,
  },
  'digest',
  {
    data_type         => 'character varying',
    default_value     => undef,
    is_nullable       => 0,
    size              => 200,
  },
  'logtime',
  {
    data_type         => 'datetime',
    default_value     => undef,
    is_nullable       => 0,
  },
  'hostname',
  {
    data_type         => 'character varying',
    default_value     => undef,
    is_nullable       => 0,
    size              => 100,
  },
  'message',
  {
    data_type         => 'character varying',
    default_value     => undef,
    is_nullable       => 0,
    size              => 1000,
  },
  'program',
  {
    data_type         => 'character varying',
    default_value     => undef,
    is_nullable       => 1,
    size              => 100,
  },
  'pid',
  { data_type         => 'integer',
    default_value     => undef,
    is_nullable       => 1 },
  'userid',
  {
    data_type         => 'character varying',
    default_value     => undef,
    is_nullable       => 1,
    size              => 20,
  },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( 'event_digest_key', ['digest'] );

=head1 RELATIONS

=head2 tags

Type: has_many

Related object: L<BuzzSaw::DB::Schema::Result::Tag>

=cut

__PACKAGE__->has_many(
  'tags',
  'BuzzSaw::DB::Schema::Result::Tag',
  { 'foreign.event' => 'self.id' },
);

1;
