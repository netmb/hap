package hapConfig::hapSchema::StaticPortpin;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("static_portpin");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "port",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
  "pin",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => 11 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2011-12-11 17:15:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:tJ6hgshgMkRDz5owfq08Ag


# You can replace this text with custom content, and it will be preserved on regeneration
1;
