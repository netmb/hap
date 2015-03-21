package hapConfig;

use strict;
use FindBin ();
use lib "$FindBin::Bin/../../../lib";    # Local libs
use warnings;

use Catalyst::Runtime '5.70';

use HAP::Init;
use JSON::XS;

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a YAML file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

##Ben Session* added
#-Debug
use Catalyst qw/-Debug
  ConfigLoader
  Static::Simple
  Session
  Session::Store::FastMmap
  Session::State::Cookie
  Unicode
  Authentication
  Authorization::Roles
  Authorization::ACL
  /;

our $VERSION = '0.90';

# Configure the application.
#
# Note that settings in hapconfig.yml (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with a external configuration file acting as an override for
# local deployment.

my $hap = new HAP::Init();

#__PACKAGE__->config( name => 'hapConfig', 'Plugin::ConfigLoader' => { file => $hap->{'BasePath'} . "/etc/hap.yml" }, mAddress => $hap->{'mAddress'});
__PACKAGE__->config(
  name                   => 'hapConfig',
  'Plugin::ConfigLoader' => { file => $hap->{'BasePath'} . "/etc/hap.yml" },
  hap                    => $hap,
  default_view           => 'index'
);

__PACKAGE__->config(
        static => {
            include_path => [
              __PACKAGE__->config->{root}, __PACKAGE__->config->{root} . '/static',
              $hap->{'WebStaticPath'}
            ],
        },
);

#__PACKAGE__->config->{'Plugin::Static::Simple'}->{include_path} = [
#  __PACKAGE__->config->{root}, __PACKAGE__->config->{root} . '/static',
#  $hap->{'WebStaticPath'}
#];

__PACKAGE__->config('Plugin::Authentication' => {
        default_realm => 'members',
        realms => {
            members => {
                credential => {
                    class => 'Password',
                    password_field => 'password',
                    password_type => 'hashed'
                },
                store => {
                    class => 'DBIx::Class',
                    user_model => 'hapModel::Users',
                    role_relation => 'map_user_role',
                    role_field => 'role',
                }
            }
        }
    });
#
#__PACKAGE__->config->{authentication}{dbic} = {
#  user_class         => 'hapModel::Users',
#  user_field         => 'username',
#  password_field     => 'password',
#  password_type      => 'hashed',
#  password_hash_type => 'SHA-1',
#};

#__PACKAGE__->config->{authorization}{dbic} = {
#  role_class           => 'hapModel::Roles',
#  role_field           => 'role',
#  role_rel             => 'map_user_role',
#  user_role_user_field => 'user',
#};





#__PACKAGE__->config->{authentication} = {
#  default_realm => 'default',
#  realms        => {
#    'default' => {
#      credential => {
#        class              => 'Password',
#        password_field     => 'password',
#        password_type      => 'hashed',
#        password_hash_type => 'SHA-1',
#      },
#      store => {
#        class                => 'DBIx::Class',
#        user_model           => 'hapModel::Users',
#        role_relation        => 'map_user_role',
#        role_field           => 'role',
#        user_role_user_field  => 'user'   
#      }
#    }
#  }
#};

# Start the application
__PACKAGE__->setup;

#'1', 'Read'
#'2', 'Write'
#'3', 'Delete'
#'33', 'GUI_Set'
#'32', 'GUI_Read'
#'31', 'Delete_Users'
#'30', 'Manage_Users'
#'29', 'Learn_IR'
#'28', 'Delete_Schedules'
#'27', 'Add_Schedules'
#'26', 'Reset_Module'
#'25', 'Push_Config'
#'24', 'Flash_Firmware'



# Authorization::ACL Rules
__PACKAGE__->deny_access_unless( "/gui/index",                [qw/32/] );
__PACKAGE__->deny_access_unless( "/gui/setDevice",            [qw/33/] );
__PACKAGE__->deny_access_unless( "/analoginput/submit",       [qw/2/] );
__PACKAGE__->deny_access_unless( "/analoginput/delete",       [qw/3/] );
__PACKAGE__->deny_access_unless( "/autonomouscontrol/submit", [qw/2/] );
__PACKAGE__->deny_access_unless( "/autonomouscontrol/delete", [qw/3/] );
__PACKAGE__->deny_access_unless( "/device/submit",            [qw/2/] );
__PACKAGE__->deny_access_unless( "/device/delete",            [qw/3/] );
__PACKAGE__->deny_access_unless( "/digitalinput/submit",      [qw/2/] );
__PACKAGE__->deny_access_unless( "/digitalinput/delete",      [qw/3/] );
__PACKAGE__->deny_access_unless( "/guiscene/submit",          [qw/2/] );
__PACKAGE__->deny_access_unless( "/guiscene/delete",          [qw/3/] );
__PACKAGE__->deny_access_unless( "/guiview/submit",           [qw/2/] );
__PACKAGE__->deny_access_unless( "/guiview/delete",           [qw/3/] );
__PACKAGE__->deny_access_unless( "/lcdgui/submit",            [qw/2/] );
__PACKAGE__->deny_access_unless( "/lcdgui/delete",            [qw/3/] );
__PACKAGE__->deny_access_unless( "/log/clear",                [qw/3/] );
__PACKAGE__->deny_access_unless( "/logicalinput/submit",      [qw/2/] );
__PACKAGE__->deny_access_unless( "/logicalinput/delete",      [qw/3/] );
__PACKAGE__->deny_access_unless( "/macro/submit",             [qw/2/] );
__PACKAGE__->deny_access_unless( "/macro/delete",             [qw/3/] );
__PACKAGE__->deny_access_unless( "/manageconfigs/setConfigs", [qw/2/] );
__PACKAGE__->deny_access_unless( "/manageconfigs/delConfigs", [qw/3/] );
__PACKAGE__->deny_access_unless( "/managefirmware/setFirmware", [qw/2/] );
__PACKAGE__->deny_access_unless( "/managefirmware/delFirmware", [qw/3/] );
__PACKAGE__->deny_access_unless( "/managemodules/flashFirmware",
  [qw/24/] );
__PACKAGE__->deny_access_unless( "/managemodules/setModules", [qw/2/] );
__PACKAGE__->deny_access_unless( "/managemodules/pushConfig",
  [qw/25/] );
__PACKAGE__->deny_access_unless( "/managemodules/resetModules",
  [qw/26/] );
__PACKAGE__->deny_access_unless( "/managescheduler/setSchedules",
  [qw/27/] );
__PACKAGE__->deny_access_unless( "/managescheduler/delSchedules",
  [qw/28/] );
__PACKAGE__->deny_access_unless( "/module/submit",        [qw/2/] );
__PACKAGE__->deny_access_unless( "/module/delete",        [qw/3/] );
__PACKAGE__->deny_access_unless( "/rangeextender/submit", [qw/2/] );
__PACKAGE__->deny_access_unless( "/rangeextender/delete", [qw/3/] );
__PACKAGE__->deny_access_unless( "/remotecontrol/submit", [qw/2/] );
__PACKAGE__->deny_access_unless( "/remotecontrol/delete", [qw/3/] );
__PACKAGE__->deny_access_unless( "/remotecontrollearned/learn",
  [qw/29/] );
__PACKAGE__->deny_access_unless( "/remotecontrollearned/submit", [qw/2/] );
__PACKAGE__->deny_access_unless( "/remotecontrollearned/delete", [qw/3/] );
__PACKAGE__->deny_access_unless( "/remotecontrolmapping/submit", [qw/2/] );
__PACKAGE__->deny_access_unless( "/remotecontrolmapping/delete", [qw/3/] );
__PACKAGE__->deny_access_unless( "/room/submit",                 [qw/2/] );
__PACKAGE__->deny_access_unless( "/room/delete",                 [qw/3/] );
__PACKAGE__->deny_access_unless( "/rotaryencoder/submit",        [qw/2/] );
__PACKAGE__->deny_access_unless( "/rotaryencoder/delete",        [qw/3/] );
__PACKAGE__->deny_access_unless( "/shutter/submit",              [qw/2/] );
__PACKAGE__->deny_access_unless( "/shutter/delete",              [qw/3/] );
__PACKAGE__->deny_access_unless( "/users/submit", [qw/30/] );
__PACKAGE__->deny_access_unless( "/users/delete", [qw/31/] );

=head1 NAME

hapConfig - Catalyst based application

=head1 SYNOPSIS

    script/hapconfig_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<hapConfig::Controller::Root>, L<Catalyst>

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
