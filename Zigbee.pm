package Zigbee;

use warnings;
use strict;

use Device::SerialPort;
use Device::XBee::API;
use Data::Dumper;


my @arr_names = ('PRINTER','NONOP','NODE5','OTHER1');
my @arr_sl    = (0x407B4FBF,0x407B4FBE,0x407B4FC3,0x407C21BD);
my @arr_pin   = ("D1","D1","D1","D1");


sub SendCmd {
	print "starting\n";

	# set up node and state 
	my ($device, $command, $device_type);
	if ($#_ == 1) { # e.g. "NODE3" "on"
		$device  = $_[0];
		$command = $_[1];
	} else { 
	        $command = $ARGV[0];
	        if ($command =~ m/^(.*) (on|off)/) {
	                $device = $1;
	                $command = $2;
		}
        }

	my $serial_port_device = Device::SerialPort->new( '/dev/ttyUSB0' ) || die $!;
	$serial_port_device->baudrate( 9600 );
	$serial_port_device->databits( 8 );
	$serial_port_device->stopbits( 1 );
	$serial_port_device->parity( 'none' );
	$serial_port_device->read_char_time( 0 );        # don't wait for each character
	$serial_port_device->read_const_time( 1000 );    # 1 second per unfulfilled "read" call
	
	#my $api = Device::XBee::API->new({  fh   => '/dev/ttyUSB0'}) || die "$!\n";
	my $api = Device::XBee::API->new( { fh => $serial_port_device } ) || die $!;
	
	my $xbee_sl = 0x0;
	my $xbee_cmd = "\x04";
	my $xbee_pin = "D1"; 
	foreach my $i (0..$#arr_names) {
		# print "$arr_names[$i]\n";
		if ($device =~ m/$arr_names[$i]/i) {
			$xbee_sl = $arr_sl[$i];
			$xbee_pin = "D1"; 
			$xbee_cmd = "\x04";
			if ($command =~ m/on/i) {
				$xbee_cmd = "\x05";
			}
		}
	}
	$api->remote_at( 
	{ sh => 0x0013A200, sl => $xbee_sl, apply_changes => "yes"},
	$xbee_pin, $xbee_cmd
	);
	print "finished\n";
}

1;
