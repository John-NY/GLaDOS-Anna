#!/usr/bin/perl
use warnings;
use strict;
use Device::SerialPort;

# Set up the serial port
# 19200, 81N on the USB FTDI device
my $port = Device::SerialPort -> new("/dev/ttyUSB0");
$port->databits(8);
$port->baudrate(9600);
$port->parity("none");
$port->stopbits(1);
my $rcv = "";
my $continue=0;

if ($#ARGV>=0) {
	print "$ARGV[0]\n";
	foreach my $arg (@ARGV)
	{
		chomp(my $out = ($arg));
		my $count_out = $port->write("$out\n");
		print "Sent     character: $out\n";
	}
        
}

print "End of Script\n";

__END__
if ($#ARGV>=0) {
	foreach my $arg (@ARGV) 
	{
		sleep(5);
		chomp(my $out = ($arg));
		printf "$out\n";
		my $count_out = $port->write("$out\n");
		print "Sent     character: $out\n";
	        sleep(1);
	}
} else {
	open(GCODE,'<',"$scriptfile") or die "cannot open $scriptfile";
	chomp( my @script = <GCODE> );
	close(GCODE);
	my $nl = $#script + 1;
	print "there are $nl lines of script\n";
#return;	
	my $count = 0;
	while ($count < $#script) {
	    # Poll to see if any data is coming in
	    my $char = $port->lookfor();
	
	    # If we get data, then print it
	    # Send a number to the arduino
	    if ($char) {
		$rcv = "$rcv$char";
	        print "Recieved character: " . $char . " \n";
		my @spl = split(/\n/,$rcv);
		my $rcv = $spl[$#spl];
	        print "buffer: " . $char . " \n";
		if($rcv =~ m/zomfg/) {
			$continue = 1;
		}
		if($rcv =~ m/ok/) {
			$continue = 1;
		}
	    } else {
		if ($continue > 0)
		{
		        sleep(1);
			$count++;
	        	my $count_out = $port->write("$script[$count]\n");
		        print "Sent     character: $script[$count] \n";
			$continue = 0;
		}
	    }
	}
}	

