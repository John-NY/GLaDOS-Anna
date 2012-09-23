package Anna;

use warnings;
use strict;

my $screen_name = ""; # hold the screen name
my $say = "says"; # name of talk command
my $client = "/home/donovan/devel/GIT_MAIN/GLaDOS/client 192.168.0.50 9140"; # name of talk command
my $screen_number = 1;

# 1: set up a session with Anna, and pipe the output to textfile.
my $anna_path = "/home/donovan/devel/GIT_MAIN/charliebot";
my $anna_chat = "/home/donovan/devel/GIT_MAIN/GLaDOS/glados.$screen_number";
#my $anna_chat = "$anna_path/output";
my $anna_err = "$anna_path/error";

sub test
{
	system "says hello";
}

sub get_anna_screen
{
	# I need to grab the server name for use in sending commands.
#	my $screen_name = "";
	open(PIPE,"screen -ls|")
		or die "cannot open\n";
	sleep 1;
	chomp( my @lines = <PIPE> );
	close(PIPE);
	#my @lines = split(/\n/,$stream);
	foreach my $l (@lines) {
		if ($l =~ m/([0-9]+\..*\.Nintendo)/)
		{
			$screen_name = $1;
			# print "$screen_name\n";
		}
	}
	return $screen_name;
	
}

sub get_anna_reply
{
	open(PIPE,"tail -n 10 $anna_chat|")
		or die "cannot open\n";
	my $success = 0;
	my $anna_said = "";
	while (<PIPE>)
	{
		chomp($_);
		if( $_ =~ m/Anna>/)
		{
			$success = 1;
			$anna_said = $_;
			$anna_said =~ s/^.*Anna>//;
			$anna_said =~ s/\"/\\\"/g;
			$anna_said =~ s/\'/\\\'/g;
			$anna_said =~ s/\(/\\\(/g;
			$anna_said =~ s/\)/\\\)/g;
		}
	}
	close (PIPE);
	if ($success == 1) {
		print "Anna said: \"$anna_said\n\"";
		system "$say $anna_said";
                # system "$client \"$anna_said\"";
		return (1==1);
	}
	return (1==0);
}

sub say_to_anna
{
	my $response = $_[0];
#	$response =~ s/[\",\',\),\(]/ /g;
 	$response =~ s/\"/\\\"/g;
 	$response =~ s/\'/\\\'/g;
	print "tried to respond at $screen_name\n";
	print "I said: $response\n";
	my $submit = "screen -S $screen_name -p $screen_number -X stuff \"$response\"";
	print "My Command: $submit\n";
	$submit = "screen -S $screen_name -p $screen_number -X stuff \"$response".'"';
	system $submit;
}

sub searchWA {
# searches  Wolfram Alpha for the search string
	my $search = "";
	$search = $_[0];
	$search =~ s/[^\w\.\,]/ /g;
	print "Starting Search for: $search\n";
	my $wa = WWW::WolframAlpha->new (
		appid => '636EG8-KY47V364JV',
	);
# 	if ($wa->available) {
# 		print "wolf available\n";
# 	} else {
# 		print "wolf unavailable\n";
# 	}
	my $vquery = $wa->validatequery(
		input => $search,
	);
	my $query = $wa->query(
		input => $search,
	);
	if ($query->success) {
		foreach my $pod (@{$query->pods}) {
			print $pod->title ."\n";
			my $sent = "";
			foreach my $subpod (@{$pod->subpods}) {
				if ($subpod->plaintext) {
					chomp( my $sanitized = $subpod->plaintext);
					$sanitized =~ s/[^\w\.\,]/ /g;
					$sent = $sent.$sanitized;
				}
				print "  Subpod\n";
				print '    plaintext: ', $subpod->plaintext, "\n" if $subpod->plaintext;
				print '    title: ', $subpod->title, "\n" if $subpod->title;
				print '    minput: ', $subpod->minput, "\n" if $subpod->minput;
				print '    moutput: ', $subpod->moutput, "\n" if $subpod->moutput;
				print '    mathml: ', $subpod->mathml, "\n" if $subpod->mathml;
				print '    img: ', $subpod->img, "\n" if $subpod->img;
			}
			system "says \"$sent\" ";
		}
# 	}
# 	if ($query->success) {
# 		foreach my $pod (@{$query->pods}) {
# 			print "$pod\n";
# 			system "says $pod";
# 		}
	} else { 
		system "says search unsuccessful";
		if ($vquery->error) {
			my $errmsg = ($vquery->error->msg);
			$errmsg =~ s/[^\w\.\,]/ /g;
			print "search failed: $errmsg\n";
			system "says error $errmsg";
		} else { # if not a good question ask the bot.
			system "says \"I will try to answer that offline\"";
			print "asking Anna $search\n";
 			&Anna::get_anna_screen;
			&Anna::say_to_anna($search);
 			&usleep(500000);
 			&Anna::get_anna_reply;
		}
		if ($query->error) {
			my $errmsg = ($query->errmsg);
			$errmsg =~ s/[^\w\.\,]/ /g;
			print "search failed: $errmsg\n";
			system "says error $errmsg";
		}
	}
}

1;
