package hapConfig::hapSchema::Homematic;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("homematic");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 63,
  },
  "module",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
  "address",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
  "homematicaddress",
  { data_type => "VARCHAR", default_value => 0, is_nullable => 0, size => 6 },
  "homematicdevicetype",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
  "notify",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "room",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "description",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "formula",
  { data_type => "VARCHAR", default_value => "", is_nullable => 1, size => 255 },
  "formuladescription",
  { data_type => "VARCHAR", default_value => "", is_nullable => 1, size => 255 },
  "config",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "channel",
  { data_type => "INT", default_value => 1, is_nullable => 1, size => 11 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-02-24 16:28:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YtdDqsf9V1vnAprlw5VZHw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
