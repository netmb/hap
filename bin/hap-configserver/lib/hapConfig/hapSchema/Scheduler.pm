package hapConfig::hapSchema::Scheduler;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("scheduler");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "cron",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 24,
  },
  "cmd",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 32,
  },
  "args",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 128,
  },
  "status",
  { data_type => "SMALLINT", default_value => 0, is_nullable => 1, size => 6 },
  "description",
  { data_type => "VARCHAR", default_value => "", is_nullable => 1, size => 255 },
  "makro",
  { data_type => "SMALLINT", default_value => 0, is_nullable => 1, size => 1 },
  "config",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-02-23 16:15:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dsJevSByGMgj4B/EO5B8zw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
