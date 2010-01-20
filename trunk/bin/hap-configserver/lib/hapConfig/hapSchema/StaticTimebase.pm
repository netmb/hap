package hapConfig::hapSchema::StaticTimebase;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("static_timebase");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 32,
  },
  "value",
  {
    data_type => "SMALLINT",
    default_value => undef,
    is_nullable => 1,
    size => 6,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-01-28 18:17:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:i5f0e9aRUqW6fGG8d9+MXA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
