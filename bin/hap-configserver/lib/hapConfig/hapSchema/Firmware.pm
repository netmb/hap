package hapConfig::hapSchema::Firmware;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("firmware");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "vmajor",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "vminor",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "vphase",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "date",
  { data_type => "VARCHAR", default_value => undef, is_nullable => 0, size => 8 },
  "filename",
  { data_type => "VARCHAR", default_value => "/", is_nullable => 0, size => 64 },
  "content",
  {
    data_type => "MEDIUMBLOB",
    default_value => undef,
    is_nullable => 0,
    size => 16777215,
  },
  "precompiled",
  { data_type => "TINYINT", default_value => 0, is_nullable => 1, size => 1 },
  "compileoptions",
  { data_type => "INT", default_value => 0, is_nullable => 1, size => 11 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2011-12-11 17:15:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sd1FmLZS3JuDcZa6lrmruA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
