package BuzzSaw::DB::Schema::Result::Log;
use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

BuzzSaw::DB::Schema::Result::Log

=cut

__PACKAGE__->table('log');

=head1 ACCESSORS

=head2 id

  data_type: integer
  default_value: nextval('log_id_seq'::regclass)
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 200

=head2 digest

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 200

=cut

__PACKAGE__->add_columns(
  'id',
  {
    data_type         => 'integer',
    default_value     => \q{nextval('log_id_seq'::regclass)},
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  'name',
  {
    data_type         => 'character varying',
    default_value     => undef,
    is_nullable       => 0,
    size              => 200,
  },
  'digest',
  {
    data_type         => 'character varying',
    default_value     => undef,
    is_nullable       => 0,
    size              => 200,
  },
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( 'name_digest', ['name', 'digest'] );
__PACKAGE__->add_unique_constraint( 'log_digest_key', ['digest'] );

1;
