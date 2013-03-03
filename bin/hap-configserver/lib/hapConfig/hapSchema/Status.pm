package hapConfig::hapSchema::Status;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("status");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "ts",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "type",
  { data_type => "TINYINT", default_value => undef, is_nullable => 1, size => 4 },
  "module",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "address",
  { data_type => "TINYINT", default_value => undef, is_nullable => 1, size => 4 },
  "status",
  { data_type => "FLOAT", default_value => undef, is_nullable => 1, size => 32 },
  "config",
  {
    data_type => "SMALLINT",
    default_value => undef,
    is_nullable => 1,
    size => 6,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-02-24 16:28:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2nffg+Ux8ar6S/lPRaR1Hw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
