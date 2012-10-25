package hapConfig::hapSchema::RemotecontrolMapping;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("remotecontrol_mapping");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "name",
  {
    data_type => "VARCHAR",
    default_value => "Remote Control",
    is_nullable => 1,
    size => 64,
  },
  "module",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
  "irkey",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
  "destdevice",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
  "destvirtmodule",
  { data_type => "INT", default_value => 0, is_nullable => 1, size => 11 },
  "destmakronr",
  { data_type => "INT", default_value => 0, is_nullable => 1, size => 11 },
  "room",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "config",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2011-12-11 17:15:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BWAYTTOIF1p3ZrgJTq+sMA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
