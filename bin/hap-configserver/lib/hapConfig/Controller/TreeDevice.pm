package hapConfig::Controller::TreeDevice;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

hapConfig::Controller::TreeDevice - Catalyst Controller

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
  my ( $self, $c ) = @_;
  my $config      = $c->session->{config};
  my @childs      = $c->model('hapModel::Device')->search( { config => $config }, { order_by => 'Name ASC' } );
  my @childrenDev = map { { id => "device/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
  my @tree        = { id => "device/0", text => "Device", children => \@childrenDev };

  @childs = $c->model('hapModel::Logicalinput')->search( { config => $config }, { order_by => 'Name ASC' } );
  my @childrenLI = map { { id => "logicalinput/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
  push @tree, { id => "logicalinput/0", text => "Logical Input", children => \@childrenLI };

  @childs = $c->model('hapModel::Digitalinput')->search( { config => $config }, { order_by => 'Name ASC' } );
  my @childrenDI = map { { id => "digitalinput/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
  push @tree, { id => "digitalinput/0", text => "Digital Input", children => \@childrenDI };

  @childs = $c->model('hapModel::Analoginput')->search( { config => $config }, { order_by => 'Name ASC' } );
  my @childrenAI = map { { id => "analoginput/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
  push @tree, { id => "analoginput/0", text => "Analog Input", children => \@childrenAI };

  @childs = $c->model('hapModel::Abstractdevice')->search( { config => $config, type => 192 }, { order_by => 'Name ASC' } );
  my @childrenSH = map { { id => "shutter/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
  push @tree, { id => "shutter/0", text => "Shutter", children => \@childrenSH };

  @childs = $c->model('hapModel::Abstractdevice')->search( { config => $config, type => 96, subtype => 240 }, { order_by => 'Name ASC' } );
  my @childrenLCD = map { { id => "lcdgui/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
  push @tree, { id => "lcdgui/0", text => "LCD GUI", children => \@childrenLCD };

  @childs = $c->model('hapModel::Abstractdevice')->search( { config => $config, type => 96, subtype => 224 }, { order_by => 'Name ASC' } );
  my @childrenRE = map { { id => "rotaryencoder/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
  push @tree, { id => "rotaryencoder/0", text => "Rotary Encoder", children => \@childrenRE };

  @childs = $c->model('hapModel::Rangeextender')->search( { config => $config }, { order_by => 'Name ASC' } );
  my @childrenRExt = map { { id => "rangeextender/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
  push @tree, { id => "rangeextender/0", text => "Range Extender", children => \@childrenRExt };

  @childs = $c->model('hapModel::RemotecontrolMapping')->search( { config => $config }, { order_by => 'Name ASC' } );
  my @childrenRemote = map { { id => "remotecontrolmapping/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
  push @tree, { id => "remotecontrolmapping/0", text => "Remote Control Mapping", children => \@childrenRemote };

  @childs = $c->model('hapModel::AcSequence')->search( { config => $config }, { order_by => 'Name ASC' } );
  my @childrenAc = map { { id => "autonomouscontrol/" . $_->id, text => $_->name, leaf => 'true' } } @childs;
  push @tree, { id => "autonomouscontrol/0", text => "Autonomous Control", children => \@childrenAc };

  @childs = ();
  my @remotes = $c->model('hapModel::Remotecontrol')->search( { config => $config }, { order_by => 'Name ASC' } );    
  foreach (@remotes) {
    my $remoteName  = $_->name;
    my $remoteId    = $_->id;
    my @learnedKeys =
      map { { id => "remotecontrollearned/" . $_->id, text => $_->name, leaf => 'true' } }
      $c->model('hapModel::RemotecontrolLearned')->search( { config => $config, remotecontrol => $remoteId }, { order_by => 'Name ASC' } );
    push @childs, { id => "remotecontrol/$remoteId", text => $remoteName, children => \@learnedKeys };
  }
  push @tree, { id => "remotecontrol/0", text => "Remote Control Learned", children => \@childs };

  $c->response->body(JSON::XS->new->utf8(0)->encode (\@tree));

}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
