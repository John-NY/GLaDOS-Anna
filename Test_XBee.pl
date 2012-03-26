#!/usr/bin/perl
use warnings;
use strict;
use Device::SerialPort;
use Device::XBee::API;
use Data::Dumper;


my @arr_names = ('PRINTER','NODE3','NODE5','OTHER1');
my @arr_sl = (0x407B4FBF,0x407B4FBE,0x407B4FC3,0x407C21BD);


print "starting\n";
my $serial_port_device = Device::SerialPort->new( '/dev/ttyUSB0' ) || die $!;
$serial_port_device->baudrate( 9600 );
$serial_port_device->databits( 8 );
$serial_port_device->stopbits( 1 );
$serial_port_device->parity( 'none' );
$serial_port_device->read_char_time( 0 );        # don't wait for each character
$serial_port_device->read_const_time( 1000 );    # 1 second per unfulfilled "read" call

#my $api = Device::XBee::API->new({  fh   => '/dev/ttyUSB0'}) || die "$!\n";
my $api = Device::XBee::API->new( { fh => $serial_port_device } ) || die $!;
$api->discover_network();

$api->remote_at( { sh => 0x0013A200, sl => $arr_sl[0], 
apply_changes => "yes"}, 'D1', "\x05");

# my $state = "\x04";
# if ($ARGV[0] =~ m/on/) {
# 	$state = "\x05";
# system "says \"The printer is probably on\"";
# } else {
# system "says \"Thank you for turning the printer off, probably\"";
# }


# 	$api->remote_at( 
# 	#{dest_h => 0x0013A200, dest_1 => 0x407B4FBF},
# 	{ sh => 0x0013A200, sl => 0x407B4FBF, apply_changes => "yes"},
# 	#{ sh => pack('H*','0013A200'), sl => pack('H*','407B4FBF'), apply_changes => "yes"},
# 	'D1',$state
# 	);

while (1 == 0) {
	#foreach my $s (@arr_sl) {
		my $rx = $api->rx({ sh => 0x0013A200, sl => $arr_sl[0] });
		$rx->{'api_datb'} = unpack('H*',$rx->{'api_data'});
		$rx->{'datb'} = unpack('H*',$rx->{'data'});
		print $rx->{'data'};
	#}	
}

my $rx = $api->discover_network();
print Dumper($rx);
$rx = $api->node_info();
die Dumper($rx);
