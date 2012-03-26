package Firecracker;

use warnings;
use strict;

use Device::SerialPort;
use ControlX10::CM17;

sub SendCmd {

	my $dev = $_[0];
	my $state = $_[1];
	my $cmd = "";
	
	my $serial_port = Device::SerialPort->new( '/dev/ttyS0' ) || die $!;
	$serial_port->baudrate( 4800 );
	$serial_port->databits( 8 );
	$serial_port->stopbits( 1 );
	$serial_port->parity( 'none' );
	$serial_port->read_char_time( 0 );        # don't wait for each character
	$serial_port->read_const_time( 1000 );    # 1 second per unfulfilled "read" call
	
	if ($dev =~ m/([A-H])/) {
		$cmd = $1; # house code 
		print "$cmd\n";
	}
	if ($dev =~ m/([0-9])/) {
		$cmd = "$cmd$1";
		print "$cmd\n";
	}
	
	if ($state =~ m/(on|off)/) {
		if ($state =~ m/on/) {
			$cmd = $cmd."J";
			print "$cmd\n";
		} else {
			$cmd = $cmd."K";
			print "$cmd\n";
		}
		&ControlX10::CM17::send($serial_port, $cmd); # Address device A1
	}
			
} # end sub SendCmd()

1;
