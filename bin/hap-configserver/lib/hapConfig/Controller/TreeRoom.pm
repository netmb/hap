package hapConfig::Controller::TreeRoom;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

hapConfig::Controller::TreeRoom - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Private {
  my ( $self, $c ) = @_;
}

sub getTreeNodes : Local {
  my ( $self, $c, $rId ) = @_;
  my $config = $c->session->{config};
  my @rooms;
  if ($rId) {
    @rooms = $c->model('hapModel::Room')->search( { config => $config, id => $rId }, { order_by => 'Name ASC' } );
  }
  else {
    @rooms = $c->model('hapModel::Room')->search( { config => $config }, { order_by => 'Name ASC' } );
  }
  my @tree;
  foreach (@rooms) {
    my $roomName = $_->name;
    my $roomId   = $_->id;

    my @childs = $c->model('hapModel::Module')->search( { config => $config, room => $roomId }, { order_by => 'Name ASC' } );
    my @childrenModule = map { { id => "module/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
    my @subTree = { id => "module/0/$roomId", text => "Module", room => $roomId, children => \@childrenModule };

    @childs = $c->model('hapModel::Device')->search( { config => $config, room => $roomId }, { order_by => 'Name ASC' } );
    my @childrenDev = map { { id => "device/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
    push @subTree, { id => "device/0/$roomId", text => "Device", room => $roomId, children => \@childrenDev };

    @childs = $c->model('hapModel::Logicalinput')->search( { config => $config, room => $roomId }, { order_by => 'Name ASC' } );
    my @childrenLI = map { { id => "logicalinput/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
    push @subTree, { id => "logicalinput/0/$roomId", text => "Logical Input", room => $roomId, children => \@childrenLI };

    @childs = $c->model('hapModel::Digitalinput')->search( { config => $config, room => $roomId }, { order_by => 'Name ASC' } );
    my @childrenDI = map { { id => "digitalinput/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
    push @subTree, { id => "digitalinput/0/$roomId", text => "Digital Input", room => $roomId, children => \@childrenDI };

    @childs = $c->model('hapModel::Analoginput')->search( { config => $config, room => $roomId }, { order_by => 'Name ASC' } );
    my @childrenAI = map { { id => "analoginput/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
    push @subTree, { id => "analoginput/0/$roomId", text => "Analog Input", room => $roomId, children => \@childrenAI };

    @childs = $c->model('hapModel::Abstractdevice')->search( { config => $config, type => 192, room => $roomId }, { order_by => 'Name ASC' } );
    my @childrenSH = map { { id => "shutter/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
    push @subTree, { id => "shutter/0/$roomId", text => "Shutter", room => $roomId, children => \@childrenSH };

    @childs = $c->model('hapModel::Homematic')->search( { config => $config, room => $roomId }, { order_by => 'Name ASC' } );
    my @childrenHM = map { { id => "homematic/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
    push @subTree, { id => "homematic/0/$roomId", text => "Homematic", room => $roomId, children => \@childrenHM };

    @childs = $c->model('hapModel::Abstractdevice')->search( { config => $config, type => 96, subtype => 240, room => $roomId }, { order_by => 'Name ASC' } );
    my @childrenLCD = map { { id => "lcdgui/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
    push @subTree, { id => "lcdgui/0/$roomId", text => "LCD GUI", room => $roomId, children => \@childrenLCD };

    @childs = $c->model('hapModel::Abstractdevice')->search( { config => $config, type => 96, subtype => 224, room => $roomId }, { order_by => 'Name ASC' } );
    my @childrenRE = map { { id => "rotaryencoder/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
    push @subTree, { id => "rotaryencoder/0/$roomId", text => "Rotary Encoder", room => $roomId, children => \@childrenRE };

    @childs = $c->model('hapModel::Rangeextender')->search( { config => $config, room => $roomId }, { order_by => 'Name ASC' } );
    my @childrenRExt = map { { id => "rangeextender/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
    push @subTree, { id => "rangeextender/0/$roomId", text => "Range Extender", room => $roomId, children => \@childrenRExt };

    @childs = $c->model('hapModel::AcSequence')->search( { config => $config, room => $roomId }, { order_by => 'Name ASC' } );
    my @childrenAc = map { { id => "autonomouscontrol/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
    push @subTree, { id => "autonomouscontrol/0/$roomId", text => "Autonomous Control", room => $roomId, children => \@childrenAc };

    @childs = $c->model('hapModel::RemotecontrolMapping')->search( { config => $config, room => $roomId }, { order_by => 'Name ASC' } );
    my @childrenRemote = map { { id => "remotecontrolmapping/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
    push @subTree, { id => "remotecontrolmapping/0/$roomId", text => "Remote Control Mapping", room => $roomId, children => \@childrenRemote };

    @childs = ();
    my @remotes = $c->model('hapModel::Remotecontrol')->search( { config => $config, room => $roomId }, { order_by => 'Name ASC' } );
    foreach (@remotes) {
      my $remoteName  = $_->name;
      my $remoteId    = $_->id;
      my @learnedKeys =
        map { { id => "remotecontrollearned/" . $_->id, text => $_->name, leaf => 'true' } }
        $c->model('hapModel::RemotecontrolLearned')->search( { config => $config, remotecontrol => $remoteId }, { order_by => 'Name ASC' } );
      push @childs, { id => "remotecontrol/$remoteId", text => $remoteName, children => \@learnedKeys };
    }
    push @subTree, { id => "remotecontrol/0", text => "Remote Control Learned", room => $roomId, children => \@childs };

    if ($rId) {
      @tree = @subTree;
    }
    else {
      push @tree, { id => "room/" . $roomId, text => $roomName, children => \@subTree };
    }
  }

  $c->response->body( JSON::XS->new->utf8(0)->encode( \@tree ) );    
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
