package Watercracker;

use warnings;
use strict;

use Time::HiRes qw(usleep nanosleep);
use Device::SerialPort;
use ControlX10::CM11;

sub SendCmd {

	#my $no_block = 0; # false = retry up to a second
	my $no_block = 1; # true = check for data only once.

	my $dev = $_[0];
	my $state = $_[1];
	my $cmd = "";
	my $data = "";
	
	my $serial_port = Device::SerialPort->new( '/dev/ttyS0' ) || die $!;
	$serial_port->baudrate( 4800 );
	$serial_port->databits( 8 );
	$serial_port->stopbits( 1 );
	$serial_port->parity( 'none' );
	$serial_port->read_char_time( 0 );        # don't wait for each character
	$serial_port->read_const_time( 1000 );    # 1 second per unfulfilled "read" call
	
	my $house = "";
	my $unit  = "";
	if ($dev =~ m/([A-H])/) {
		$house = $1; # house code 
	}
	if ($dev =~ m/([0-9])/) {
		$unit  = "$1";
	}
	
	if ($state =~ m/(on|off)/) {
		if ($state =~ m/on/) {
			$cmd = "J";
			print "$house$unit $house$cmd\n";
		} else {
			$cmd = "K";
			print "$house$unit $house$cmd\n";
		}
#  use ControlX10::CM11;
#  send_cm11($serial_port, 'A1');            # send() - address
#  send_cm11($serial_port, 'AJ');            # send() - function
#  $data = receive_cm11($serial_port);           # receive_buffer()
#  $data = read_cm11($serial_port, $no_block);       # read()
		&ControlX10::CM11::send($serial_port, "$house$unit"); # Address device A1
		&ControlX10::CM11::send($serial_port, "$house$cmd"); # Address device A1
		$data = &ControlX10::CM11::receive_cm11($serial_port);           # receive_buffer()
		print "received: $data\n";
		$data = &ControlX10::CM11::read_cm11($serial_port, $no_block);       # read()
		print "read: $data\n";
	}
			
} # end sub SendCmd()

1;
