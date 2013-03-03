package hapConfig::hapSchema::MakroByDatagram;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("makro_by_datagram");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "source",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "destination",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "mtype",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "address",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "v0",
  { data_type => "VARCHAR", default_value => undef, is_nullable => 1, size => 5 },
  "v1",
  { data_type => "VARCHAR", default_value => undef, is_nullable => 1, size => 5 },
  "v2",
  { data_type => "VARCHAR", default_value => undef, is_nullable => 1, size => 5 },
  "makro",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "description",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "config",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
  "active",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 1 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-02-24 16:28:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:KQo1sQ2HGmMBZj8zN1dT/A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
