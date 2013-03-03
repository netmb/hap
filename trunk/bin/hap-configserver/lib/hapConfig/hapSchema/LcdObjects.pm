package hapConfig::hapSchema::LcdObjects;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("lcd_objects");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "abstractdevid",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "type",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "offset",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "string",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => 65535,
  },
  "configobject",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => 65535,
  },
  "config",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-02-24 16:28:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:veVtVcY5TkyoI9wiVlnjjA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
