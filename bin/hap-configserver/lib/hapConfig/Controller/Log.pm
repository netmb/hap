package hapConfig::Controller::Log;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

hapConfig::Controller::Log - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Private {
 my ( $self, $c ) = @_;

 $c->response->body('Matched hapConfig::Controller::Log in Log.');
}

sub getPDF : Local {
 my ( $self, $c ) = @_;
 if ( $c->request->params->{all} eq "true" ) {

  #$c->stash->{log} = [ $c->model('hapModel::Log')->search()->all ];
  $c->stash->{log} = [
   map {
    {
     'time'    => $_->time,
     'pid'     => $_->pid,
     'source'  => $_->source,
     'type'    => $_->type,
     'message' => escape( $_->message )
    }
     } $c->model('hapModel::Log')->search()->all
  ];
 }
 else {
  my @logs;
  my @data = split( /,/, $c->request->params->{ids} );
  foreach (@data) {

   #push @logs, $c->model('hapModel::Log')->search( { id => $_ } )->all;
   @logs = [
    map {
     {
      'time'    => $_->time,
      'pid'     => $_->pid,
      'source'  => $_->source,
      'type'    => $_->type,
      'message' => escape( $_->message )
     }
      } $c->model('hapModel::Log')->search( { id => $_ } )->all
   ];
  }
  $c->stash->{log} = \@logs;
 }
 ## this is a fucking-fix, that only needs to be used, when running in standalone-mode
 ## system-calls always return -1 ..
 ## look here: http://catalyst.perl.org/calendar/2006/12
 {
  no warnings 'redefine';    # right here, you can tell bad things will happen
  local *Template::Latex::system = sub {
   my $ret = system(@_);

   my ($filename) = $_[0] =~ m[\\input{(.*?)}];
   my $fh = new IO::File "${filename}.log"
     or die "Unable to open pdflatex logfile ${filename}.log: $!";

   my $line;
   while ( defined( $_ = $fh->getline ) ) {
    $line = $_;
   }

   return 0
     if $line =~
     /^Output written on ${filename}.pdf \(\d+ pages?, \d+ bytes?\).$/;
   return $ret;
    }
    if $c->engine =~ /^Catalyst::Engine::HTTP/;

  $c->stash->{template} = 'main/pdf.tt2';
  if ( $c->forward('hapConfig::View::TT') ) {
   $c->response->content_type('application/pdf');
   $c->response->header( 'Content-Disposition',
    "attachment; filename=Log-" . time() . ".pdf" );
  }
 }

}

sub getLog : Local {
 my ( $self, $c ) = @_;
 if ( $c->request->params->{all} eq "true" ) {
  $c->stash->{log} = [
   map {
    {
     'time'    => $_->time,
     'pid'     => $_->pid,
     'source'  => $_->source,
     'type'    => $_->type,
     'message' => $_->message
    }
     } $c->model('hapModel::Log')->search()->all
  ];
 }
 else {
  my @logs;
  my @data = split( /,/, $c->request->params->{ids} );
  foreach (@data) {
   push @logs, map {
    {
     'time'    => $_->time,
     'pid'     => $_->pid,
     'source'  => $_->source,
     'type'    => $_->type,
     'message' => $_->message
    }
   } $c->model('hapModel::Log')->search( { id => $_ } )->all;
  }
  $c->stash->{log} = \@logs;
 }
 $c->stash->{template} = 'main/log.tt2';
}

sub getNewLogEntries : Local {
 my ( $self, $c, $auto, $id ) = @_;
 my $rs    = $c->model('hapModel::Log');
 my $last  = $rs->get_column('id')->max;
 my $total = $rs->count;
 my $start = $c->request->params->{start};
 $start = 0 if ( !defined($start) );
 if ( defined($id) && $auto == 1 ) {
  $c->stash->{log} = [
   map {
    {
     'id'      => $_->id,
     'pid'     => $_->pid,
     'time'    => $_->time,
     'source'  => $_->source,
     'type'    => $_->type,
     'message' => $_->message
    }
     } $c->model('hapModel::Log')->search( { id => { '>', ($id) } },
    { rows => 50, order_by => 'ID DESC, Time DESC' } )->all
  ];
 }
 else {
  $c->stash->{log} = [
   map {
    {
     'id'      => $_->id,
     'pid'     => $_->pid,
     'time'    => $_->time,
     'source'  => $_->source,
     'type'    => $_->type,
     'message' => $_->message
    }
     } $c->model('hapModel::Log')->search(
    { id => { '<=', ( $last - $start ) } },
    { rows => 50, order_by => 'ID DESC, Time DESC' }
     )->all
  ];
 }
 $c->stash->{total}  = $total;
 $c->stash->{lastID} = $last;
 $c->forward('View::JSON');
}

sub clear : Local {
 my ( $self, $c ) = @_;
 if ( $c->request->params->{all} eq 'true' ) {
  $c->model('hapModel::Log')->search()->delete;
  my $dbh = $c->model('hapModel')->schema->storage->dbh;
  $dbh->do('alter table log auto_increment=1');
 }
 else {
  my $jsonData = JSON::XS->new->utf8(0)->decode( $c->request->params->{data} );
  foreach (@$jsonData) {
   $c->model('hapModel::Log')->search( { id => $_ } )->delete_all;
  }
 }
 $c->stash->{success} = \1;
 $c->stash->{info}    = "Done.";
 $c->forward('View::JSON');
}

sub escape {
 my $str = $_[0];
 $str =~ s/%/\\%/g;
 return $str;
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
