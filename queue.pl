#!/usr/bin/perl
use warnings;
use strict;
use Date::Manip;

my @months = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");

if ($#ARGV == 1)
{
	my $time = $ARGV[0];
	my $says = $ARGV[1];
	$says =~ s/[\W]/ /;
	
	my $date = new Date::Manip::Date;
	$date->parse_format("%H:%m %d %b %Y");
	my $err = $date->parse($time);
	my @adate = $date->value();
	my $stime = sprintf "%.2d:%.2d %s %d %d", $adate[3], $adate[4], $months[$adate[1]-1], $adate[2], $adate[0];

# 	my $stime = &UnixDate($time,"%H:%m %d %b %Y");
# 	print "$stime\n";

	my $submit = sprintf "echo \"says \\\"%s\\\"\"|at %s", $says, $stime;
	print "$submit\n";
	system $submit;
}
