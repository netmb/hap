package hapConfig::Controller::FileUpload;

use strict;
use warnings;
use base 'Catalyst::Controller';
use HAP::FirmwareBuilder;

=head1 NAME

hapConfig::Controller::FileUpload - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Private {
  my ( $self, $c ) = @_;

  $c->response->body('Matched hapConfig::Controller::FileUpload in FileUpload.');
}

sub getFile : Local {
  my ( $self, $c ) = @_;
  my $upload = $c->request->uploads->{file};
  my $fName = $upload->filename;
  $fName =~ s/.*\\(.*\.\w{3})$/$1/; # Internet Explorer sucks 
  my $parm;
  my $rs;
  if ( $fName =~ /ha-(\d+)-(\d+)-(\d+)-(\d{8})\.zip/ ) {    # firmware-file
    $upload->copy_to( '/tmp/' . $fName );
    my $fwOpts      = new HAP::FirmwareBuilder->checkPreCompiled( '/tmp/' . $fName );
    my $preCompiled = 0;
    if ( defined($fwOpts) ) {
      $preCompiled = 1;
    }
    my $data = {
      name           => $fName,
      vmajor         => $1,
      vminor         => $2,
      vphase         => $3,
      date           => $4,
      filename       => $fName,
      precompiled    => $preCompiled,
      compileoptions => $fwOpts,
      content        => $upload->slurp,
    };
    $rs         = $c->model('hapModel::Firmware')->create($data);
    $data->{id} = $rs->id;
    $parm       = "firmwareid :" . $rs->id;
  }
  else {
    $upload->copy_to( $c->config->{WebStaticPath} . "/images/" . $fName );
    $parm = "";
  }
  $c->response->body("{success : true, error: 'Done.', $parm }");    #hmm, upload dialog doesnt like application/json
}

sub deleteImage : Local {
  my ( $self, $c ) = @_;
  my $deletedFiles = unlink( $c->config->{WebStaticPath} . "/images/" . $c->request->params->{file} );
  if ( $deletedFiles > 0 ) {
    $c->stash->{success} = \1;
  }
  else {
    $c->stash->{success} = \0;
  }
  $c->forward('View::JSON');
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
