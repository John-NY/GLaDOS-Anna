#!/usr/bin/perl
use warnings;
use strict;
use Device::SerialPort;
use Device::XBee::API;
use Data::Dumper;
use Time::HiRes qw(usleep nanosleep);

use lib '/usr/lib/perl5/User';
require Firecracker;
require Watercracker;
require Zigbee;

# These are the XBee Nodes
my @arr_names = ('PRINTER','NONOP','NODE5','OTHER1');
my @arr_sl    = (0x407B4FBF,0x407B4FBE,0x407B4FC3,0x407C21BD);
my @arr_pin   = ("D1","D1","D1","D1");

# These are the X-10 Nodes
my @x10_names = ('tranceiver','kitchen fan','node3');
my @x10_id    = ('A1','A2','A3');

# set up node and state 
my ($device, $command, $device_type);
if ($#ARGV == 1) { # e.g. "NODE3" "on"
	$device  = $ARGV[0];
	$command = $ARGV[1];
} else { 
        $command = $ARGV[0];
        if ($command =~ m/^(.*) (on|off)/) {
                $device = $1;
                $command = $2;
	}
}

# Find device from the xbee list or the X-10 list
$device_type = "";
foreach my $i (0..$#arr_names) {
	if ($device =~ m/$arr_names[$i]/i) {
		$device_type = "xbee";
		print "XBee $ARGV[0] $ARGV[1]\n";
		&Zigbee::SendCmd(@ARGV);
	}
}
print "test\n";
# if not xbee then try x-10
if ($device_type !~ m/xbee/) {
	foreach my $i (0..$#x10_names) { 
		# search for name
		if ($device =~ m/$x10_names[$i]/i) {
			my $x10_base = $x10_id[$i];
	#		print "Firecracker $x10_base $command\n";
	#		&Firecracker::SendCmd($x10_base,$command);
	#		&usleep(1000000);
			print "Watercracker $x10_base $command\n";
			&Watercracker::SendCmd($x10_base,$command);
		} else {
			# search for ID
			if ($device =~ m/$x10_id[$i]/i) {
				my $x10_base = $x10_id[$i];
	#			print "Firecracker $x10_base $command\n";
	#			&Firecracker::SendCmd($x10_base,$command);
	#			&usleep(1000000);
				print "Watercracker $x10_base $command\n";
				&Watercracker::SendCmd($x10_base,$command);
			}
		}
	}
} 

