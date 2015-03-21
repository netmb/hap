#!/usr/bin/perl
$| = 1;

=head1 NAME

hap-cmd.pl - The Home Automation Project Command-Line-Client

=cut

use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use IO::Socket::INET;
use HAP::Init;
use HAP::Parser;
use JSON::XS;
my $sock;
my $json = new JSON::XS();
my $cObj;

BEGIN {
	if ( $^O =~ "dos" || $^O =~ "MSWin32" ) {
		eval { require Win32::Console };
		Win32::Console->import();
		sub ReadMode { }
	}
	else {
		eval { require Term::ReadKey };
		Term::ReadKey->import();
		use constant STD_INPUT_HANDLE       => 0;
		use constant ENABLE_PROCESSED_INPUT => 0;
	}
}

my @help;

sub getHelp {
	my ($search) = @_;
	my $result = "";
	foreach (@help) {
		if ( $_ =~ /^$search.*/ ) {
			my $tmp = $_;
			$tmp =~ s/^\d+\s(.*)/$1/;
			$result .= $tmp . "\n";
		}
	}
	return $result;
}

sub getRest {
	my ($search) = @_;
	my $result = 0;
	my $tmp;
	foreach (@help) {
		if ( $_ =~ /^$search.*/ ) {
			$result++;
			$tmp = $_;
		}
	}
	if ( $result == 1 ) {
		$tmp =~ s/$search//;
		$tmp =~ s/ .*//;
		if ( $tmp =~ /^<.*/ ) { $result = "^"; }
		else { $result = $tmp; }
	}
	else { $result = "^"; }
	return $result;
}

sub execHAPCmd {
	my ($obj) = @_;
	if ( !$obj->{source} ) {
		$obj->{source} = $cObj->{SessionSource};
	}
	print $sock "$obj->{vlan} $obj->{source} $obj->{destination} $obj->{mtype} $obj->{device} $obj->{v0} $obj->{v1} $obj->{v2}\n";
	print <$sock> . "\n";
	$sock->autoflush(1);
	return;
}

sub passthroughHMCmd {
  my ($line) = @_;
  if ($line) {
    print $sock "$line\n";
	  print <$sock> . "\n";
	  $sock->autoflush(1);
	  return;
  }
}

my $cfg = new HAP::Init( FILE => "$FindBin::Bin/../etc/hap.yml", SKIP_DB => 1 );
$sock = new IO::Socket::INET( PeerAddr => $cfg->{MessageProcessor}->{Host}, PeerPort => $cfg->{MessageProcessor}->{Port}, Proto => 'tcp' );
$sock or die "Can\'t connect to Message-Processor:$!";
my $object;
eval {
	local $SIG{ALRM} = sub { die 'Alarm'; };
	alarm 1;
	$object = <$sock>;
	alarm 0;
};
if ($@) {
	print "Can\'t connect to Message-Processor\n";
	exit 1;
}    
$cObj = $json->decode($object);
my $sessionSource = $cObj->{SessionSource};
my $prompt        = $cfg->{HAPCmdPrompt};
my $emptyPrompt   = $prompt;
$emptyPrompt =~ s/./ /g;
my $lang = $cfg->{HAPCmdLang};
open( FH, "<hap-cmd-" . lc($lang) . ".hlp" );

while (<FH>) {
	my $tmp = $_;
	$tmp =~ s/^\s+//;
	$tmp =~ s/\n//;
	push( @help, $tmp );
}
close FH;
my $bs = 0;
my $w32Con;
if ( $^O =~ "dos" || $^O =~ "MSWin32" ) { $bs = 1; }
if ( $bs == 0 ) {

	#  system "clear";
}
else {
	$w32Con = new Win32::Console(STD_INPUT_HANDLE);
	$w32Con->Mode(ENABLE_PROCESSED_INPUT);
	system "cls";
}
if ( uc($lang) eq "EN" ) {
	print "Home Automation Project Command Shell 1.0\n\n";
	print "Press \"exit\" or \"quit\" to terminate.\n\n";
}
elsif ( uc($lang) eq "DE" ) {
	print "Home Automation Project Kommando Interpreter 1.0\n\n";
	print "Zum Beenden \"exit\" oder \"quit\" eingeben.\n\n";
}
else { die "The defined language is not supported ...\n"; }
my $line    = "";
my $cursor  = 0;
my $tabFlag = 0;
my @history;
my $historyCount = -1;
my $historyIndex = 0;

while (1) {
	my $key;
	my @input;
	my $k;
	my $delline;
	print "$prompt$line";
	if ( $bs == 0 ) { ReadMode 4; }
	while (1) {
		if ( $bs == 0 ) {
			while ( not defined( $key = ReadKey(-1) ) ) { select( undef, undef, undef, 0.00001 ) }
			$k = ord($key);
			if ( $k == 27 ) {
				$key = ReadKey(-1);
				$key = ReadKey(-1);
				$k <<= 8;
				$k += ord($key);
				if ( ord($key) == 49 || ord($key) == 51 || ord($key) == 52 ) { $key = ReadKey(-1); }
			}
		}
		else {
			while ( not @input = $w32Con->Input() && not defined $input[0] && $input[0] == 1 && $input[1] == 0 ) { select( undef, undef, undef, 0.00001 ) }
			if ( defined $input[0] ) {
				if ( $input[5] == 8 ) { $k = 127; }
				elsif ( $input[5] == 0 ) {
					if    ( $input[3] == 35 ) { $k = 6964; }
					elsif ( $input[3] == 36 ) { $k = 6961; }
					elsif ( $input[3] == 37 ) { $k = 6980; }
					elsif ( $input[3] == 38 ) { $k = 6977; }
					elsif ( $input[3] == 39 ) { $k = 6979; }
					elsif ( $input[3] == 40 ) { $k = 6978; }
					elsif ( $input[3] == 46 ) { $k = 6963; }
					elsif ( $input[3] == 16 ) { $k = 65535; }
					else { $k = 0; }
				}
				else {
					$k   = $input[5];
					$key = chr($k);
				}
			}
			else { $k = 65535; }
		}
		if ( $k != 9 ) { $tabFlag = 0; }
		if ( $k == 10 || $k == 13 || $k == 9 || $k == 63 ) {
			if ( $k == 10 || $k == 13 ) {
				if ( $historyCount < 0 || $history[$historyCount] ne $line ) {
					if ( $historyCount < 63 ) { $historyCount++; }
					else {
						for ( my $i = 0 ; $i < 63 ; $i++ ) { $history[$i] = $history[ $i + 1 ]; }
					}
					$history[$historyCount] = $line;
				}
				$historyIndex = $historyCount + 1;
				$line .= " ";
			}
			if ( $k == 9 ) {
				if ( $tabFlag == 0 ) { $tabFlag = 1; }
				else { $k = 63; }
			}
			$line .= "^$k";
			last;
		}
		elsif ( $k == 6980 ) {
			if ( $cursor > 0 ) {
				$cursor--;
				print "\r$prompt" . substr( $line, 0, $cursor );
			}
		}
		elsif ( $k == 6979 ) {
			if ( $cursor < length($line) ) {
				$cursor++;
				print "\r$prompt" . substr( $line, 0, $cursor );
			}
		}
		elsif ( $k == 6961 ) {
			$cursor = 0;
			print "\r$prompt";
		}
		elsif ( $k == 6964 ) {
			$cursor = length($line);
			print "\r$prompt$line";
		}
		elsif ( $k == 6963 ) {
			if ( $cursor < length($line) ) {
				$delline = $line;
				$delline =~ s/./ /g;
				print "\r$prompt$delline";
				$line = substr( $line, 0, $cursor ) . substr( $line, $cursor + 1 );
				print "\r$prompt$line";
				print "\r$prompt" . substr( $line, 0, $cursor );
			}
		}
		elsif ( $k == 127 ) {
			if ( $cursor > 0 ) {
				$delline = $line;
				$delline =~ s/./ /g;
				print "\r$prompt$delline";
				$line = substr( $line, 0, $cursor - 1 ) . substr( $line, $cursor );
				$cursor--;
				print "\r$prompt$line";
				print "\r$prompt" . substr( $line, 0, $cursor );
			}
		}
		elsif ( $k > 31 && $k < 127 ) {
			$line = substr( $line, 0, $cursor ) . $key . substr( $line, $cursor );
			$cursor++;
			print "\r$prompt$line";
			print "\r$prompt" . substr( $line, 0, $cursor );
		}
		elsif ( $k == 6977 ) {
			if ( $historyIndex > 0 ) {
				$historyIndex--;
				$delline = $line;
				$delline =~ s/./ /g;
				print "\r$prompt$delline";
				$line   = $history[$historyIndex];
				$cursor = length($line);
				print "\r$prompt$line";
			}
		}
		elsif ( $k == 6978 ) {
			if ( $historyIndex < $historyCount ) {
				$historyIndex++;
				$delline = $line;
				$delline =~ s/./ /g;
				print "\r$prompt$delline";
				$line   = $history[$historyIndex];
				$cursor = length($line);
				print "\r$prompt$line";
			}
		}
		elsif ( $k != 65535 ) { print chr(7); }
	}
	if ( $bs == 0 ) { ReadMode 0; }
	if ( substr( $line, 0, 1 ) eq "e" || substr( $line, 0, 1 ) eq "q" ) { last; }
	else {
		my $parser = new HAP::Parser($cfg);
		my ( $err, $obj, $hmConfigDgram ) = $parser->parse( $line, $sessionSource );
		if ( $k == 63 && $err =~ /^\d+ .*/ ) {
			print "\n" . &getHelp($err);
			$line =~ s/\^63//;
		}
		elsif ( $k == 9 && $err =~ /^\d+ .*/ ) {
			my $rest = &getRest($err);
			print "\r";
			$line =~ s/\^9//;
			if ( $rest ne "^" ) {
				$line .= "$rest ";
				$cursor  = length($line);
				$tabFlag = 0;
			}
		}
		else {
			print "\n";
			if ($err) {
				if ( $err =~ /^\s.*/ ) { print $emptyPrompt; }
				print $err;
			}
			elsif ($hmConfigDgram) { &passthroughHMCmd($line); }
			else { &execHAPCmd($obj); }
			##print "\n\n";
			$line   = "";
			$cursor = 0;
		}
	}
}
