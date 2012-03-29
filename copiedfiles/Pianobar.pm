package Pianobar;
# for now this is a stupid one-way communication

use warnings;
use strict;
use Time::HiRes qw(usleep nanosleep);

my $screen_name = ""; # hold the screen name
my $screen_number = 4; # hold screen number

sub get_screen
{
	# I need to grab the server name for use in sending commands.
	# Let's assume for now that the LAST SCREEN CREATED is the one.
	open(PIPE,"screen -ls|")
		or die "cannot open\n";
	sleep 1;
	chomp( my @lines = <PIPE> );
	close(PIPE);
	#my @lines = split(/\n/,$stream);
	foreach my $l (@lines) {
		if ($l =~ m/([0-9]+\..*\.darktower)/)
		{
			$screen_name = $1;
			print "$screen_name\n";
			#return $screen_name;
		}
	}
	return $screen_name;
	
}

sub command
{
	my $cmd = $_[0];
	$cmd =~ s/([\W])/\\$1/g; #^\w\.\,\ ]//g;
	my $submit = "screen -S $screen_name -p $screen_number -X stuff \"$cmd\"";
	system $submit;
}

sub change_station
{
	my $station = $_[0];
	$station =~ s/[\W]//g; #^\w\.\,\ ]//g;
	print "set station to $station\n";
	my @stations = ("Catalyst","(ambient|chill|down)","cogwheel","dubstep","noise","Ether","house","Quick","kick","opera","orbital","trance");
	my $p = 0; my $changed = ( 1 == 0 );
	foreach my $s (@stations) {
		if ($station =~ m/$s/i) {
			printf "station $station matches station $s\n";
			my $submit = "screen -S $screen_name -X -p $screen_number stuff s";
			print "$submit\n";
			system $submit;
			usleep(200000);
			$submit = "screen -S $screen_name -p $screen_number -X stuff \"$p\"";
			system $submit;
			$changed = ( 1 == 1);
		}
		$p++;
	}
#          0) q S Catalyst
#          1) q   Chill / Downtempo Radio
#          2) q S Cogwheel
#          3) q   Dubstep Radio
#          4) q   Einsturzende Neubauten Radio
#          5) q S Ether
#          6) q   House Radio
#          7)  Q  jdonovan813's QuickMix
#          8) q S Kick
#          9) q   Opera Radio
#         10) q   Orbital Radio
#         11)     Trance Radio
	@stations = ("0","1","2","3","4","5",'6','7','8','9','10','11');
	$p = 0;
	if (!$changed) {
		foreach my $s (@stations) {
			if ($station =~ m/^$s$/i) {
				printf "station $station matches station $s\n";
				my $submit = "screen -S $screen_name -X stuff s";
				print "$submit\n";
				system $submit;
				usleep(200000);
				$submit = "screen -S $screen_name -X stuff \"$p\"";
				system $submit;
				$changed = ( 1 == 1);
			}
			$p++;
		}
	}
		
} # end sub change_station

1;
