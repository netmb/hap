package hapConfig::Controller::JSON;
use strict;
use warnings;
use base 'Catalyst::Controller';
use Image::Size;

=head1 NAME

hapConfig::Controller::JSON - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub getModules : Local {
  my ( $self, $c ) = @_;
  $c->stash->{modules} =
    [ map { { 'id' => $_->id, 'name' => $_->name, 'firmware' => $_->firmwareid } }
      $c->model('hapModel::Module')->search( { config => $c->session->{config} }, { order_by => 'Name ASC' } )->all ];
  $c->forward('View::JSON');
}

sub getNotifyModules : Local {
  my ( $self, $c ) = @_;
  my @tmp =
    map { { 'id' => $_->id, 'name' => $_->name } }
    $c->model('hapModel::Module')->search( { config => $c->session->{config} }, { order_by => 'Name ASC' } )->all;
  push @tmp, { 'id' => 0, 'name' => "None" };
  push @tmp, { 'id' => -255, 'name' => "Broadcast" };
  push @tmp, { 'id' => -240, 'name' => "Multicast 240" };
  push @tmp, { 'id' => -241, 'name' => "Multicast 241" };
  push @tmp, { 'id' => -242, 'name' => "Multicast 242" };
  push @tmp, { 'id' => -243, 'name' => "Multicast 243" };
  push @tmp, { 'id' => -244, 'name' => "Multicast 244" };
  push @tmp, { 'id' => -245, 'name' => "Multicast 245" };
  push @tmp, { 'id' => -246, 'name' => "Multicast 246" };
  push @tmp, { 'id' => -247, 'name' => "Multicast 247" };
  push @tmp, { 'id' => -248, 'name' => "Multicast 248" };
  push @tmp, { 'id' => -249, 'name' => "Multicast 249" };
  push @tmp, { 'id' => -250, 'name' => "Multicast 250" };
  push @tmp, { 'id' => -251, 'name' => "Multicast 251" };
  push @tmp, { 'id' => -252, 'name' => "Multicast 252" };
  push @tmp, { 'id' => -253, 'name' => "Multicast 253" };
  $c->stash->{modules} = \@tmp;
  $c->forward('View::JSON');
}

sub getUpstreamModules : Local {
  my ( $self, $c ) = @_;
  my @tmp =
    map { { 'id' => $_->id, 'name' => $_->name } }
    $c->model('hapModel::Module')->search( { config => $c->session->{config} }, { order_by => 'Name ASC' } )->all;
  push @tmp, { 'id' => 0, 'name' => "Self" };
  $c->stash->{modules} = \@tmp;
  $c->forward('View::JSON');
}

sub getFreeModuleAddresses : Local {
  my ( $self, $c, $moduleID ) = @_;
  my @used = $c->model('hapModel::Module')->search(
    config => $c->session->{config},
    { columns => [qw/id address/] }
  )->all;
  my @unused;
  for ( 1 .. 223 ) {
    my $addr  = $_;
    my $found = 0;
    foreach (@used) {
      if ( $_->address == $addr && $moduleID != $_->id ) {
        $found = 1;
        last;
      }
    }
    push @unused, { 'address' => $addr } if ( $found == 0 );
  }
  $c->stash->{addresses} = \@unused;
  $c->forward('View::JSON');
}

sub checkAddress : Local {
  my ( $self, $c, $moduleID, $address, $id ) = @_;
  $c->stash->{success} = 'true';
  if ( $c->model('hapModel::Device')->search( { config => $c->session->{config}, module => $moduleID, address => $address, id => { '!=', $id } } )->first ) {
    $c->stash->{success} = \0;
  }
  elsif (
    $c->model('hapModel::Logicalinput')->search( { config => $c->session->{config}, module => $moduleID, address => $address, id => { '!=', $id } } )->first )
  {
    $c->stash->{success} = \0;
  }
  elsif (
    $c->model('hapModel::Analoginput')->search( { config => $c->session->{config}, module => $moduleID, address => $address, id => { '!=', $id } } )->first )
  {
    $c->stash->{success} = \0;
  }
  elsif (
    $c->model('hapModel::Digitalinput')->search( { config => $c->session->{config}, module => $moduleID, address => $address, id => { '!=', $id } } )->first )
  {
    $c->stash->{success} = \0;
  }
  elsif (
    $c->model('hapModel::Abstractdevice')->search( { config => $c->session->{config}, module => $moduleID, address => $address, id => { '!=', $id } } )->first )
  {
    $c->stash->{success} = \0;
  }
  elsif (
    $c->model('hapModel::Homematic')->search( { config => $c->session->{config}, module => $moduleID, address => $address, id => { '!=', $id } } )->first )
  {
    $c->stash->{success} = \0;
  }
  $c->forward('View::JSON');
}

sub checkPortPin : Local {
  my ( $self, $c, $moduleID, $portPin, $id ) = @_;
  ( my $port, my $pin ) = split( /-/, $portPin );
  $c->stash->{success} = 'true';
  if (
    $c->model('hapModel::Device')->search( { config => $c->session->{config}, module => $moduleID, port => $port, pin => $pin, id => { '!=', $id } } )->first )
  {
    $c->stash->{success} = \0;
  }
  elsif (
    $c->model('hapModel::Logicalinput')->search( { config => $c->session->{config}, module => $moduleID, port => $port, pin => $pin, id => { '!=', $id } } )
    ->first )
  {
    $c->stash->{success} = \0;
  }
  elsif (
    $c->model('hapModel::Digitalinput')->search( { config => $c->session->{config}, module => $moduleID, port => $port, pin => $pin, id => { '!=', $id } } )
    ->first )
  {
    $c->stash->{success} = \0;
  }
  elsif (
    $c->model('hapModel::Analoginput')->search( { config => $c->session->{config}, module => $moduleID, port => $port, pin => $pin, id => { '!=', $id } } )
    ->first )
  {
    $c->stash->{success} = \0;
  }
  $c->forward('View::JSON');
}

sub getAddresses : Local {
  my ( $self, $c, $moduleID, $address ) = @_;
  $c->stash->{addresses} = [ map { { 'name' => $_ } } &fillAddress( $self, $c, $c->session->{config}, $moduleID, $address ) ];
  $c->forward('View::JSON');
}

sub getPortPins : Local {
  my ( $self, $c, $moduleID, $portPin ) = @_;
  $c->stash->{portpins} = [ map { { 'name' => $_ } } &fillPortPin( $self, $c, $c->session->{config}, $moduleID, $portPin ) ];
  $c->forward('View::JSON');
}

sub getRooms : Local {
  my ( $self, $c ) = @_;
  $c->stash->{rooms} =
    [ map { { 'id' => $_->id, 'name' => $_->name } }
      $c->model('hapModel::Room')->search( { config => $c->session->{config} }, { order_by => 'Name ASC' } )->all ];
  $c->forward('View::JSON');
}

sub getUpstreamInterfaces : Local {
  my ( $self, $c ) = @_;
  $c->stash->{upstreaminterfaces} =
    [ map { { 'id' => $_->type, 'name' => $_->name } } $c->model('hapModel::StaticInterfaces')->search( {}, { order_by => 'Name ASC' } )->all ];
  $c->forward('View::JSON');
}

sub getTimeBase : Local {
  my ( $self, $c ) = @_;
  $c->stash->{timebase} = [ map { { 'value' => $_->value, 'name' => $_->name } } $c->model('hapModel::StaticTimebase')->all ];
  $c->forward('View::JSON');
}

sub getWeekdays : Local {
  my ( $self, $c ) = @_;
  $c->stash->{days} = [ map { { 'value' => $_->value, 'name' => $_->name } } $c->model('hapModel::StaticWeekdays')->all ];
  $c->forward('View::JSON');
}

sub getDeviceTypes : Local {
  my ( $self, $c ) = @_;
  $c->stash->{devicetypes} = [ map { { 'id' => $_->type, 'name' => $_->name } } $c->model('hapModel::StaticDevicetypes')->search({}, { order_by => 'Name ASC' }) ];
  $c->forward('View::JSON');
}

sub getHomematicDeviceTypes : Local {
  my ( $self, $c ) = @_;
  $c->stash->{homematicdevicetypes} = [ map { { 'id' => $_->id, 'name' => $_->name } } $c->model('hapModel::StaticHomematicdevicetypes')->search({}, { order_by => 'Name ASC' }) ];
  $c->forward('View::JSON');
}

sub getDigitalInputTypes : Local {
  my ( $self, $c ) = @_;
  $c->stash->{devicetypes} = [ map { { 'id' => $_->type, 'name' => $_->name } } $c->model('hapModel::StaticDigitalinputtypes')->all ];
  $c->forward('View::JSON');
}

sub getLogicalInputTemplates : Local {
  my ( $self, $c ) = @_;
  $c->stash->{templates} = [ map { { 'id' => $_->id, 'name' => $_->name, 'type' => $_->type } } $c->model('hapModel::StaticLogicalinputtemplates')->all ];
  $c->forward('View::JSON');
}

sub getASInputValueTemplates : Local {
  my ( $self, $c ) = @_;
  $c->stash->{templates} = [ map { { 'id' => $_->id, 'name' => $_->name, 'type' => $_->type } } $c->model('hapModel::StaticInputvaluetemplates')->all ];
  $c->forward('View::JSON');
}

sub getStartModes : Local {
  my ( $self, $c ) = @_;
  $c->stash->{startmodes} = [ map { { 'id' => $_->type, 'name' => $_->name } } $c->model('hapModel::StaticStartmodes')->all ];
  $c->forward('View::JSON');
}

sub getSchedulerCommands : Local {
  my ( $self, $c ) = @_;
  my @schedulerCmds =  map { { 'id' => $_->id, 'name' => $_->name } } $c->model('hapModel::StaticSchedulercommands')->all ;
  my @macros =  map { { 'id' => $_->id, 'name' => $_->name } } $c->model('hapModel::Makro')->all ;
  push (@schedulerCmds, @macros);
  $c->stash->{scheduler} = [@schedulerCmds];
  $c->forward('View::JSON');
}

sub getDevices : Local {
  my ( $self, $c, $qType ) = @_;
#  if ( $qType eq "shutter" ) {
#    $c->stash->{devices} =
#      [ map { { 'id' => $_->id, 'name' => $_->name } }
#        $c->model('hapModel::Device')->search( { config => $c->session->{config}, -or => [ type => 16, type => 64 ] }, { order_by => 'Name ASC' } )->all ];
#  }
##TO DO## OR Verknp. 16 64 .... in WHERE
#  elsif ( $qType eq "standardOutputs" ) {
    $c->stash->{devices} =
      [ map { { 'id' => $_->id, 'name' => $_->name } }
        $c->model('hapModel::Device')->search( { config => $c->session->{config} }, { order_by => 'Name ASC' } )->all ];
#  }
  $c->forward('View::JSON');
}

sub getShutterDevices : Local {
  my ( $self, $c ) = @_;
  $c->stash->{devices} =
    [ map { { 'id' => $_->id, 'name' => $_->name } }
      $c->model('hapModel::Device')->search( { config => $c->session->{config}, -or => [ type => 16, type => 64, type => 65, type => 66, type => 67 ] }, { order_by => 'Name ASC' } )->all ];
  $c->forward('View::JSON');    
}

sub getAllDevices : Local {
  my ( $self, $c, $mId ) = @_;
  my @devices;
  my @tmp =
    map { { 'address' => $_->address, 'name' => $_->name } }
    $c->model('hapModel::Device')->search( { config => $c->session->{config}, module => $mId }, { order_by => 'Name ASC' } )->all;
  push @devices, @tmp;
  @tmp =
    map { { 'address' => $_->address, 'name' => $_->name } }
    $c->model('hapModel::LogicalInput')->search( { config => $c->session->{config}, module => $mId }, { order_by => 'Name ASC' } )->all;
  push @devices, @tmp;
  @tmp =
    map { { 'address' => $_->address, 'name' => $_->name } }
    $c->model('hapModel::AnalogInput')->search( { config => $c->session->{config}, module => $mId }, { order_by => 'Name ASC' } )->all;
  push @devices, @tmp;
  @tmp =
    map { { 'address' => $_->address, 'name' => $_->name } }
    $c->model('hapModel::DigitalInput')->search( { config => $c->session->{config}, module => $mId }, { order_by => 'Name ASC' } )->all;
  push @devices, @tmp;
  @tmp =
    map { { 'address' => $_->address, 'name' => $_->name } }
    $c->model('hapModel::Abstractdevice')->search( { config => $c->session->{config}, module => $mId }, { order_by => 'Name ASC' } )->all;
  push @devices, @tmp;
  @tmp =
    map { { 'address' => $_->address, 'name' => $_->name } }
    $c->model('hapModel::Homematic')->search( { config => $c->session->{config}, module => $mId }, { order_by => 'Name ASC' } )->all;
  push @devices, @tmp;
  $c->stash->{devices} = \@devices;
  $c->forward('View::JSON');
}

sub getAllTriggerDevices : Local {
  my ( $self, $c, $mId ) = @_;
  my @devices;
  my @tmp =
    map { { 'address' => $_->address, 'name' => $_->name } }
    $c->model('hapModel::AnalogInput')->search( { config => $c->session->{config}, module => $mId }, { order_by => 'Name ASC' } )->all;
  push @devices, @tmp;
  @tmp =
    map { { 'address' => $_->address, 'name' => $_->name } }
    $c->model('hapModel::DigitalInput')->search( { config => $c->session->{config}, module => $mId }, { order_by => 'Name ASC' } )->all;
  push @devices, @tmp;
  $c->stash->{devices} = \@devices;
  $c->forward('View::JSON');
}


sub getMacros : Local {
  my ( $self, $c ) = @_;
  $c->stash->{macros} =
    [ map { { 'id' => $_->id, 'name' => $_->name } }
      $c->model('hapModel::Makro')->search( { config => $c->session->{config} }, { order_by => 'Name ASC' } )->all ];
  $c->forward('View::JSON');
}

sub getLogicalInputs : Local {
  my ( $self, $c, $type ) = @_;
  $c->stash->{logicalinputs} =
    [ map { { 'id' => $_->id, 'name' => $_->name } }
      $c->model('hapModel::Logicalinput')->search( { config => $c->session->{config}, type => $type }, { order_by => 'Name ASC' } )->all ];
  $c->forward('View::JSON');
}

sub getAbstractDevices : Local {
  my ( $self, $c, $type, $subType ) = @_;
  if ( defined($type) && defined($subType) ) {
    $c->stash->{abstractdevices} = [
      map { { 'id' => $_->id, 'name' => $_->name } } $c->model('hapModel::Abstractdevice')->search(
        {
          config  => $c->session->{config},
          type    => $type,
          subtype => $subType
        },
        { order_by => 'Name ASC' }
        )->all
    ];
  }
  $c->forward('View::JSON');
}

sub getGuiViews : Local {
  my ( $self, $c ) = @_;
  $c->stash->{views} = [ map { { 'id' => $_->id, 'name' => $_->name } } $c->model('hapModel::GuiView')->search( { config => $c->session->{config} } )->all ];
  $c->forward('View::JSON');
}

sub getGuiScenes : Local {
  my ( $self, $c ) = @_;
  $c->stash->{scenes} = [ map { { 'id' => $_->id, 'name' => $_->name } } $c->model('hapModel::GuiScene')->search( { config => $c->session->{config} } )->all ];
  $c->forward('View::JSON');
}

sub getImages : Local {
  my ( $self, $c ) = @_;
  my @images = &fetchImages( $c->config->{root} . '/static/images/gui', '/images/gui' );    # core images
  push @images, &fetchImages( $c->config->{WebStaticPath} . '/images', '/images' );
  $c->stash->{images}  = \@images;
  $c->stash->{success} = \1;
  $c->forward('View::JSON');
}

sub fillAddress() {
  my ( $self, $c, $cfg, $m, $address ) = @_;
  my @a = $c->model('hapModel::AllAddresses')->search( {}, { bind => [ $cfg, $m, $cfg, $m, $cfg, $m, $cfg, $m, $cfg, $m, $cfg, $m ] } )->all;
  my @b = map { $_->address } @a;
  push @b, $address if ( $address && $address ne 'undefined' && $address ne '');
  @b = sort { $a <=> $b } (@b);
  my @c;
  foreach (@b) {
    push @c, [$_];
  }
  return @c;
}

sub fillPortPin() {
  my ( $self, $c, $cfg, $m, $portpin ) = @_;
  my %toSkip;
  my $rc = $c->model('hapModel::Module')->search( id => $m )->first;
  my $fwOpts = 0;
  if ($rc) {
  	$fwOpts = $rc->firmwareoptions;
  }
  if (($fwOpts & 8) == 8) { # wireless
    $toSkip{"3-0"} = 1;
    $toSkip{"3-1"} = 1;
  }
  if (($fwOpts & 16) == 16) { # can
    $toSkip{"1-4"} = 1;
    $toSkip{"1-5"} = 1;
    $toSkip{"1-6"} = 1;
    $toSkip{"1-7"} = 1;
  }
  my @a = $c->model('hapModel::AllPortPin')->search( {}, { bind => [ $cfg, $m, $cfg, $m, $cfg, $m, $cfg, $m ] } )->all;
  my @b = map { $_->portpin } @a;
  push @b, $portpin if ( defined($portpin) );
  @b = sort (@b);
  my @c;
  foreach (@b) {
  	if (!$toSkip{$_}) {
      push @c, [$_];
  	}
  }
  return @c;
}

sub fetchImages() {
  my $dir     = shift;
  my $relPath = shift;
  opendir( DIR, $dir );
  my @images;
  while ( defined( my $e = readdir(DIR) ) ) {
    next if ( $e eq "." or $e eq ".." );
    my $path = $dir . "/" . $e;
    if ( !-d $path ) {
      my $size = -s $path;
      ( my $w,, my $h ) = imgsize($path);
      push @images, { name => $e, size => $size, w => $w, h => $h, url => "$relPath/$e" };
    }
  }
  closedir(DIR);
  return @images;
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
