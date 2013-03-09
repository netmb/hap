package hapConfig::hapSchema::Module;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("module");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "uid",
  {
    data_type => "VARCHAR",
    default_value => "000000",
    is_nullable => 1,
    size => 6,
  },
  "name",
  {
    data_type => "VARCHAR",
    default_value => "Module",
    is_nullable => 1,
    size => 64,
  },
  "address",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
  "startmode",
  { data_type => "INT", default_value => 217, is_nullable => 0, size => 11 },
  "ccuaddress",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
  "devoption",
  { data_type => "INT", default_value => 0, is_nullable => 1, size => 11 },
  "oldaddress",
  { data_type => "INT", default_value => 0, is_nullable => 1, size => 11 },
  "description",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "buzzerlevel",
  { data_type => "INT", default_value => 0, is_nullable => 1, size => 11 },
  "vlan",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "canvlan",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "cryptkey0",
  { data_type => "INT", default_value => 0, is_nullable => 1, size => 11 },
  "cryptkey1",
  { data_type => "INT", default_value => 0, is_nullable => 1, size => 11 },
  "cryptkey2",
  { data_type => "INT", default_value => 0, is_nullable => 1, size => 11 },
  "cryptkey3",
  { data_type => "INT", default_value => 0, is_nullable => 1, size => 11 },
  "cryptkey4",
  { data_type => "INT", default_value => 0, is_nullable => 1, size => 11 },
  "cryptkey5",
  { data_type => "INT", default_value => 0, is_nullable => 1, size => 11 },
  "cryptkey6",
  { data_type => "INT", default_value => 0, is_nullable => 1, size => 11 },
  "cryptkey7",
  { data_type => "INT", default_value => 0, is_nullable => 1, size => 11 },
  "cryptoption",
  { data_type => "INT", default_value => 0, is_nullable => 1, size => 11 },
  "bridgemode",
  { data_type => "INT", default_value => 0, is_nullable => 1, size => 11 },
  "libouncedelay",
  { data_type => "INT", default_value => 10, is_nullable => 1, size => 11 },
  "lishortdelay",
  { data_type => "INT", default_value => 50, is_nullable => 1, size => 11 },
  "lilongdelay",
  { data_type => "INT", default_value => 150, is_nullable => 1, size => 11 },
  "receivebuffer",
  { data_type => "INT", default_value => 4, is_nullable => 1, size => 11 },
  "dimmerticlength",
  { data_type => "INT", default_value => 60, is_nullable => 1, size => 11 },
  "dimmercyclelength",
  { data_type => "INT", default_value => 6, is_nullable => 1, size => 11 },
  "firmwareoptions",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "firmwareversion",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 18,
  },
  "istimeserver",
  { data_type => "TINYINT", default_value => undef, is_nullable => 1, size => 1 },
  "room",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "isccu",
  { data_type => "TINYINT", default_value => 0, is_nullable => 1, size => 1 },
  "isccumodule",
  { data_type => "TINYINT", default_value => 0, is_nullable => 1, size => 1 },
  "firmwareid",
  { data_type => "INT", default_value => 0, is_nullable => 1, size => 11 },
  "currentfirmwareoptions",
  { data_type => "INT", default_value => 0, is_nullable => 1, size => 11 },
  "currentfirmwareid",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "upstreammodule",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "upstreaminterface",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "mcastgroups",
  { data_type => "INT", default_value => 32768, is_nullable => 1, size => 11 },
  "config",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-03-08 13:40:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mMV/EgZxz2v+/oYnigL6Qg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
