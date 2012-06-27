package BuzzSaw::DataSource; # -*-perl-*-
use strict;
use warnings;

our $VERSION = '@LCFG_VERSION@';

# $Id:$
# $Source:$
# $Revision:$
# $HeadURL:$
# $Date:$

use UNIVERSAL::require;

use Moose::Role;
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw(Bool);

requires 'next_entry', 'reset';

subtype 'BuzzSawParser' => as role_type('BuzzSaw::Parser');
coerce 'BuzzSawParser'
    => from 'Str'
    => via { my $module = $_;
             if ( $module !~ m/^BuzzSaw::Parser::/ ) {
                 $module = 'BuzzSaw::Parser::' . $module;
             }
             $module->require or die $UNIVERSAL::require::ERROR;
             return $module->new()
            };

has 'catalogue' => (
    does => 'BuzzSaw::Catalogue',
    is   => 'rw',
);

has 'parser' => (
    isa      => 'BuzzSawParser',
    is       => 'ro',
    coerce   => 1,
    required => 1,
);

has 'readall' => (
    isa     => Bool,
    is      => 'rw',
    default => 0,
);

no Moose::Role;

1;
