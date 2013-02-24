package hapConfig::hapSchema::AcTypes;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("ac_types");
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
  "type",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "description",
  {
    data_type => "MEDIUMTEXT",
    default_value => undef,
    is_nullable => 1,
    size => 16777215,
  },
  "inports",
  { data_type => "TINYINT", default_value => 0, is_nullable => 1, size => 4 },
  "outports",
  { data_type => "TINYINT", default_value => 1, is_nullable => 1, size => 4 },
  "shortname",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 64,
  },
  "display",
  {
    data_type => "VARCHAR",
    default_value => "{}",
    is_nullable => 1,
    size => 255,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-02-23 16:15:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:O8fyoMq6j3aeH1nAJCMK6Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
