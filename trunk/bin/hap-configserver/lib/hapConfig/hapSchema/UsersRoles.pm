package hapConfig::hapSchema::UsersRoles;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("users_roles");
__PACKAGE__->add_columns(
  "user",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "role",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("user", "role");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-01-28 18:17:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:eLtwmkeqxYOVTwH7O1gVnQ


# You can replace this text with custom content, and it will be preserved on regeneration
#__PACKAGE__->has_one('rolename' => 'hapConfig::hapSchema::Roles',{'foreign.id' => 'self.role'});
1;
