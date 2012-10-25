use inc::Module::Install;

name 'hapConfig';
all_from 'lib/hapConfig.pm';

requires 'Catalyst::Runtime' => '5.7010';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'YAML'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported format


catalyst_par_classes(qw/DBIx::Class::Storage::DBI::mysql/);
catalyst_par_script('hapconfig_server.pl');

catalyst;
install_script glob('script/*.pl');
auto_install;
WriteAll;
