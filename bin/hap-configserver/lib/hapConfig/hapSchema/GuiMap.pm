package hapConfig::hapSchema::GuiMap;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("gui_map");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "sourcearea",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
  "destarea",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
  "x",
  { data_type => "DOUBLE", default_value => 0, is_nullable => 1, size => 64 },
  "y",
  { data_type => "DOUBLE", default_value => 0, is_nullable => 1, size => 64 },
  "width",
  { data_type => "DOUBLE", default_value => 0, is_nullable => 1, size => 64 },
  "height",
  { data_type => "DOUBLE", default_value => 0, is_nullable => 1, size => 64 },
  "scene",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "config",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2011-12-11 17:15:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Z8s2cj5a8kHsVwLNtvI+ng


# You can replace this text with custom content, and it will be preserved on regeneration
1;
