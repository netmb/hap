package hapConfig::hapSchema::Digitalinput;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("digitalinput");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "name",
  {
    data_type => "VARCHAR",
    default_value => "Digital Input",
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
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "notify",
  { data_type => "INT", default_value => 0, is_nullable => 1, size => 11 },
  "samplerate",
  { data_type => "FLOAT", default_value => 0, is_nullable => 0, size => 32 },
  "trigger0",
  { data_type => "FLOAT", default_value => undef, is_nullable => 1, size => 32 },
  "trigger0hyst",
  { data_type => "FLOAT", default_value => undef, is_nullable => 1, size => 32 },
  "trigger0notify",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "trigger1",
  { data_type => "FLOAT", default_value => undef, is_nullable => 1, size => 32 },
  "trigger1hyst",
  { data_type => "FLOAT", default_value => undef, is_nullable => 1, size => 32 },
  "trigger1notify",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "makro",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "room",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "config",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 1 },
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
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-02-23 16:15:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZlVjTJwHds9v9HaSvlNMug


# You can replace this text with custom content, and it will be preserved on regeneration
1;
