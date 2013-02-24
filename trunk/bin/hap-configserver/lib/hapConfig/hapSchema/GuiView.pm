package hapConfig::hapSchema::GuiView;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("gui_view");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 64,
  },
  "isdefault",
  {
    data_type => "SMALLINT",
    default_value => undef,
    is_nullable => 1,
    size => 1,
  },
  "config",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-02-23 16:15:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:MlbOKqC4T7Als3gwF9jqUQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
