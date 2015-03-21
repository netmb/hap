package hapConfig::Controller::TreeModule;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

hapConfig::Controller::TreeModule - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Private {
  my ( $self, $c ) = @_;

  $c->response->body('Matched hapConfig::Controller::TreeModule in TreeModule.');
}

sub getTreeNodes : Local {
  my ( $self, $c, $mId ) = @_;
  my $config = $c->session->{config};
  my @modules;
  if ($mId) {
    @modules = $c->model('hapModel::Module')->search( { config => $config, id => $mId }, { order_by => 'Name ASC' } );
  }
  else {
    @modules = $c->model('hapModel::Module')->search( { config => $config }, { order_by => 'Name ASC' } );
  }
  my @tree;
  foreach (@modules) {
    my $moduleName = $_->name;
    my $moduleId   = $_->id;

    my @childs = $c->model('hapModel::Device')->search( { config => $config, module => $moduleId }, { order_by => 'Name ASC' } );
    my @childrenDev = map { { id => "device/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
    my @subTree = { id => "device/0/$moduleId", text => "Device", module => $moduleId, children => \@childrenDev };

    @childs = $c->model('hapModel::Logicalinput')->search( { config => $config, module => $moduleId }, { order_by => 'Name ASC' } );
    my @childrenLI = map { { id => "logicalinput/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
    push @subTree, { id => "logicalinput/0/$moduleId", text => "Logical Input", module => $moduleId, children => \@childrenLI };

    @childs = $c->model('hapModel::Digitalinput')->search( { config => $config, module => $moduleId }, { order_by => 'Name ASC' } );
    my @childrenDI = map { { id => "digitalinput/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
    push @subTree, { id => "digitalinput/0/$moduleId", text => "Digital Input", module => $moduleId, children => \@childrenDI };

    @childs = $c->model('hapModel::Analoginput')->search( { config => $config, module => $moduleId }, { order_by => 'Name ASC' } );
    my @childrenAI = map { { id => "analoginput/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
    push @subTree, { id => "analoginput/0/$moduleId", text => "Analog Input", module => $moduleId, children => \@childrenAI };

    @childs = $c->model('hapModel::Abstractdevice')->search( { config => $config, type => 192, module => $moduleId }, { order_by => 'Name ASC' } );
    my @childrenSH = map { { id => "shutter/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
    push @subTree, { id => "shutter/0/$moduleId", text => "Shutter", module => $moduleId, children => \@childrenSH };

    @childs = $c->model('hapModel::Homematic')->search( { config => $config, module => $moduleId }, { order_by => 'Name ASC' } );
    my @childrenHM = map { { id => "homematic/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
    push @subTree, { id => "homematic/0/$moduleId", text => "Homematic", module => $moduleId, children => \@childrenHM };

    @childs =
      $c->model('hapModel::Abstractdevice')->search( { config => $config, type => 96, subtype => 240, module => $moduleId }, { order_by => 'Name ASC' } );
    my @childrenLCD = map { { id => "lcdgui/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
    push @subTree, { id => "lcdgui/0/$moduleId", text => "LCD GUI", module => $moduleId, children => \@childrenLCD };

    @childs =
      $c->model('hapModel::Abstractdevice')->search( { config => $config, type => 96, subtype => 224, module => $moduleId }, { order_by => 'Name ASC' } );
    my @childrenRE = map { { id => "rotaryencoder/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
    push @subTree, { id => "rotaryencoder/0/$moduleId", text => "Rotary Encoder", module => $moduleId, children => \@childrenRE };

    @childs = $c->model('hapModel::Rangeextender')->search( { config => $config, module => $moduleId }, { order_by => 'Name ASC' } );
    my @childrenRExt = map { { id => "rangeextender/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
    push @subTree, { id => "rangeextender/0/$moduleId", text => "Range Extender", module => $moduleId, children => \@childrenRExt };

    @childs = $c->model('hapModel::AcSequence')->search( { config => $config, module => $moduleId }, { order_by => 'Name ASC' } );
    my @childrenAc = map { { id => "autonomouscontrol/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
    push @subTree, { id => "autonomouscontrol/0/$moduleId", text => "Autonomous Control", module => $moduleId, children => \@childrenAc };

    @childs = $c->model('hapModel::RemotecontrolMapping')->search( { config => $config, module => $moduleId }, { order_by => 'Name ASC' } );
    my @childrenRemote = map { { id => "remotecontrolmapping/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
    push @subTree, { id => "remotecontrolmapping/0/$moduleId", text => "Remote Control Mapping", module => $moduleId, children => \@childrenRemote };

    @childs = ();
    my @remotes = $c->model('hapModel::Remotecontrol')->search( { config => $config, module => $moduleId }, { order_by => 'Name ASC' } );
    foreach (@remotes) {
      my $remoteName  = $_->name;
      my $remoteId    = $_->id;
      my @learnedKeys =
        map { { id => "remotecontrollearned/" . $_->id, text => $_->name, leaf => 'true' } }
        $c->model('hapModel::RemotecontrolLearned')->search( { config => $config, remotecontrol => $remoteId }, { order_by => 'Name ASC' } );
      push @childs, { id => "remotecontrol/$remoteId", text => $remoteName, children => \@learnedKeys };
    }
    push @subTree, { id => "remotecontrol/0", text => "Remote Control Learned", children => \@childs };
    
    if ($mId) {
      @tree = @subTree ;
    }
    else {
      push @tree, { id => "module/" . $moduleId, text => $moduleName, module => $moduleId, leaf => \0, children => \@subTree };
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
