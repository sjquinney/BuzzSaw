package BuzzSaw::DB::Schema::Result::Tag;
use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

BuzzSaw::DB::Schema::Result::Tag

=cut

__PACKAGE__->table('tag');

=head1 ACCESSORS

=head2 id

  data_type: integer
  default_value: nextval('tag_id_seq'::regclass)
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 20

=head2 event

  data_type: integer
  default_value: undef
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  'id',
  {
    data_type         => 'integer',
    default_value     => \q{nextval('tag_id_seq'::regclass)},
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  'name',
  {
    data_type         => 'character varying',
    default_value     => undef,
    is_nullable       => 0,
    size              => 20,
  },
  'event',
  {
    data_type         => 'integer',
    default_value     => undef,
    is_foreign_key    => 1,
    is_nullable       => 0,
  },
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( 'name_event', ['name', 'event'] );

=head1 RELATIONS

=head2 event

Type: belongs_to

Related object: L<BuzzSaw::DB::Schema::Result::Event>

=cut

__PACKAGE__->belongs_to(
  'event',
  'BuzzSaw::DB::Schema::Result::Event',
  { id => 'event' },
  {},
);

1;
