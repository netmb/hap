package hapConfig::Model::hapModel;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
  schema_class => 'hapConfig::hapSchema',
  connect_info => [
    'dbi:mysql:hap',
    'hap',
    'password',
    {
      mysql_enable_utf8 => 1,
      on_connect_do     => [ "SET NAMES 'utf8'", "SET CHARACTER SET 'utf8'" ]
    }    

  ],
);

=head1 NAME

hapConfig::Model::hapModel - Catalyst DBIC Schema Model
=head1 SYNOPSIS

See L<hapConfig>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<hapConfig::hapSchema>

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
