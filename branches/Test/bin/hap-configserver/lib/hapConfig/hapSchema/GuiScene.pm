package hapConfig::hapSchema::GuiScene;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("gui_scene");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "viewid",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "isdefault",
  { data_type => "SMALLINT", default_value => 0, is_nullable => 1, size => 1 },
  "centerx",
  { data_type => "SMALLINT", default_value => 0, is_nullable => 1, size => 1 },
  "centery",
  { data_type => "SMALLINT", default_value => 0, is_nullable => 1, size => 1 },
  "name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 64,
  },
  "config",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2011-12-11 17:15:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:k9tlsxo+gcOACWBEvBFlsg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
