=head1 NAME

HAP::Log - The Home Automation Project Log-Module

=head1 DESCRIPTION

Logs HAP-Events from different sources to different destinations (file/db) 

=cut

package HAP::Log;
use strict;
use Time::Local;
use IO::File;

sub new {
  my ( $class, $c, %init ) = @_;
  my $self = { c => $c };

  $self->{logHandle}   = new IO::File(">>$self->{c}->{LogFile}");
  $self->{destination} = 3;                                         # defaults to File and DB
  $self->{level}       = 0;
  if ( defined( $init{LEVEL} ) ) {
    &setLevel( $self, $init{LEVEL} );
  }
  if ( defined( $init{DESTINATION} ) ) {
    &setDestination( $self, $init{DESTINATION} );
  }
  if ( defined( $init{ID} ) ) {
    $self->{ID} = $init{ID};
  }

  return bless $self, $class;
}

sub setLevel {    ### NOT IN USE
  my ( $self, $logLevels ) = @_;

  foreach (@$logLevels) {
    if ( $_ =~ /.*Info.*/i ) {
      $self->{level} |= 1;
    }
    elsif ( $_ =~ /.*Warning.*/i ) {
      $self->{level} |= 2;
    }
    elsif ( $_ =~ /.*Error.*/i ) {
      $self->{level} |= 4;
    }
    elsif ( $_ =~ /.*Status.*/i ) {
      $self->{level} |= 8;
    }
  }
  return $self->{level};
}

sub setDestination {
  my ( $self, $logDests ) = @_;
  $self->{destination} = 0;    
  foreach (@$logDests) {
    if ( $_ =~ /.*File.*/i ) {
      $self->{destination} |= 1;
    }
    elsif ( $_ =~ /.*DB.*/i ) {
      $self->{destination} |= 2;
    }
    elsif ( $_ =~ /.*Scheduler.*/i ) {
      $self->{destination} |= 4;
    }
  }
  return $self->{destination};
}

sub add {
  my ( $self, $pid, $source, $type, $message, $status ) = @_;
  $message .= " [$status]" if ( defined($status) );

  # 0-none, 1-file, 2-db, 4-Scheduler
  if ( ( $self->{destination} & 1 ) == 1 ) {
    my ( $sec, $min, $hour, $mday, $mon, $year ) = localtime(time);
    if (defined $self->{logHandle}) {
      $self->{logHandle}->printf( "%4d-%02d-%02d %02d:%02d:%02d ", $year + 1900, $mon + 1, $mday, $hour, $min, $sec );
      $self->{logHandle}->printf( "%5d %-13.13s %-7.7s %s\n", $pid, $source, $type, "$message" );
      $self->{logHandle}->flush();
    }

  }
  if ( ( $self->{destination} & 2 ) == 2 ) {
    my ( $sec, $min, $hour, $mday, $mon, $year ) = localtime(time);
    my $time = sprintf( "%4d-%02d-%02d %02d:%02d:%02d ", $year + 1900, $mon + 1, $mday, $hour, $min, $sec );
    $self->{sth} = $self->{c}->{dbh}->prepare("INSERT INTO log SET Time=\'$time\', Pid = $pid, Source= \"$source\", Type = \"$type\", Message = \"$message\"");
    $self->{sth}->execute;
  }
  if ( ( $self->{destination} & 4 ) == 4 && defined( $self->{ID} ) && defined($status) ) {
    $self->{sth} = $self->{c}->{dbh}->prepare("UPDATE scheduler SET Status=$status WHERE ID=$self->{ID}");
    $self->{sth}->execute;
  }
}

1;
