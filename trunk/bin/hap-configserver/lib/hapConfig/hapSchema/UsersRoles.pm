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


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2013-02-24 16:28:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:njT4yORSSYsWpdfxgDBF2A


# You can replace this text with custom content, and it will be preserved on regeneration
# belongs_to():
#   args:
#     1) Name of relationship, DBIC will create accessor with this name
#     2) Name of the model class referenced by this relationship
#     3) Column name in *this* table
__PACKAGE__->belongs_to(user => 'hapConfig::hapSchema::Users', 'user');

# belongs_to():
#   args:
#     1) Name of relationship, DBIC will create accessor with this name
#     2) Name of the model class referenced by this relationship
#     3) Column name in *this* table
__PACKAGE__->belongs_to(user => 'hapConfig::hapSchema::Roles', 'role');


#__PACKAGE__->has_one('rolename' => 'hapConfig::hapSchema::Roles',{'foreign.id' => 'self.role'});
1;
