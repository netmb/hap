package hapConfig::hapSchema::AcObjects;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("ac_objects");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "sequence",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "module",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "object",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "type",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "prop1",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "prop2",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "prop3",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "configobject",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => 65535,
  },
  "x",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "config",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2011-12-11 17:15:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4BuNUcisGLRD8PLr/GI9IA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
