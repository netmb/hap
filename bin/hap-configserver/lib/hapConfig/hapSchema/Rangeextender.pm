package hapConfig::hapSchema::Rangeextender;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("rangeextender");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "name",
  {
    data_type => "VARCHAR",
    default_value => "Range Extender",
    is_nullable => 1,
    size => 64,
  },
  "module",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "destmodule",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "room",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "config",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-03-08 13:40:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bWJOT6IsObl9tZ4qZyjC3g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
