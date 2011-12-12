package hapConfig::hapSchema::Logicalinput;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("logicalinput");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "name",
  {
    data_type => "VARCHAR",
    default_value => "Logical Input",
    is_nullable => 1,
    size => 64,
  },
  "module",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
  "address",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
  "port",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
  "pin",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
  "type",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "notify",
  { data_type => "INT", default_value => 0, is_nullable => 1, size => 11 },
  "makro",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "room",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "formula",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "formuladescription",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "config",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 1 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2011-12-11 17:15:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sNJvKK+GOIC2ANMW84jvNw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
