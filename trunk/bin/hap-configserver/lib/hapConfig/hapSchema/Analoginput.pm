package hapConfig::hapSchema::Analoginput;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("analoginput");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "name",
  {
    data_type => "VARCHAR",
    default_value => "Analog Input",
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
  "measure",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 512,
  },
  "unit",
  { data_type => "VARCHAR", default_value => "", is_nullable => 0, size => 32 },
  "correction",
  { data_type => "FLOAT", default_value => undef, is_nullable => 1, size => 32 },
  "notify",
  { data_type => "INT", default_value => 0, is_nullable => 1, size => 11 },
  "samplerate",
  { data_type => "FLOAT", default_value => 10, is_nullable => 0, size => 32 },
  "trigger0",
  { data_type => "FLOAT", default_value => 0, is_nullable => 1, size => 32 },
  "trigger0hyst",
  { data_type => "INT", default_value => 0, is_nullable => 1, size => 11 },
  "trigger0notify",
  { data_type => "INT", default_value => 0, is_nullable => 1, size => 11 },
  "trigger1",
  { data_type => "FLOAT", default_value => 0, is_nullable => 1, size => 32 },
  "trigger1hyst",
  { data_type => "INT", default_value => 0, is_nullable => 1, size => 11 },
  "trigger1notify",
  { data_type => "INT", default_value => 0, is_nullable => 1, size => 11 },
  "status",
  { data_type => "FLOAT", default_value => undef, is_nullable => 1, size => 32 },
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


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-03-08 13:40:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5zguDmxDFThTah49i5ubjQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
