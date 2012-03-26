#!/usr/bin/perl
use warnings;
use strict;

use Device::SerialPort;
use ControlX10::CM11;

my $no_block = 0; # false = retry up to a second
#my $no_block = 1; # true = check for data only once.


# $serial_port is an object created using Win32::SerialPort
#     or Device::SerialPort depending on OS
my $serial_port = Device::SerialPort->new( '/dev/ttyS0' ) || die $!;
$serial_port->baudrate( 4800 );
$serial_port->databits( 8 );
$serial_port->stopbits( 1 );
$serial_port->parity( 'none' );
$serial_port->read_char_time( 0 );        # don't wait for each character
$serial_port->read_const_time( 1000 );    # 1 second per unfulfilled "read" call

my $data = &ControlX10::CM11::receive_buffer($serial_port);
$data = &ControlX10::CM11::read($serial_port, $no_block);
# my $percent = &ControlX10::CM11::dim_level_decode('GE'); # 40%

#     &ControlX10::CM11::send($serial_port, 'A1'); # Address device A1
#     &ControlX10::CM11::send($serial_port, 'AJ'); # Turn device ON
#     # House Code 'A' present in both send() calls
    
while (1 == 1)
{
#     &ControlX10::CM11::send($serial_port, 'A'.'ALL_OFF');
    &ControlX10::CM11::send($serial_port, 'A1'); # Address device A1
    &ControlX10::CM11::send($serial_port, 'AJ'); # Turn device ON
#     &ControlX10::CM11::send($serial_port, 'A1J'); # Address device A1
    sleep(2);
#     &ControlX10::CM11::send($serial_port, 'A'.'ALL_ON');
    &ControlX10::CM11::send($serial_port, 'A1'); # Address device A1
    &ControlX10::CM11::send($serial_port, 'AK'); # Turn device OFF
#     &ControlX10::CM11::send($serial_port, 'A1K'); # Address device A1
    sleep(2);
} 
