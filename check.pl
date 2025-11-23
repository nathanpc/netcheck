#!/usr/bin/env perl

use strict;
use warnings;
use autodie;

use DBI;
use Carp;
use JSON::PP;
use Time::HiRes;
use Data::Dumper;
use LWP::UserAgent;
use File::Basename;

# Global configuration variables.
our $script_dir = dirname(__FILE__);
our $config = undef;

# Loads the user configuration.
sub load_config {
	my ($loc) = @_;
	
	# Open JSON file and read its entire contents.
	open(my $fh, '<:encoding(UTF-8)', $loc);
	my $contents = join('', <$fh>);
	close($fh);
	
	return JSON::PP->new->utf8->decode($contents);
}

# Checks HTTP endpoints.
sub check_http {
	my ($url) = @_;
	my $success = 0;
	
	# Check if we have a URL.
	if (not defined $url) {
		print "usage: $0 http url\n";
		croak "Did not provide a URL for the HTTP check, you must pass a URL parameter " .
			"after the HTTP command";
	}
	
	# Set up LWP.
	my $ua = LWP::UserAgent->new(
		agent => 'netcheck',
		timeout => $config->{'timeout'}
	);
	
	# Perform GET request and time it.
	my $time_req = Time::HiRes::time();
	my $resp = $ua->get($url);
	$time_req = (Time::HiRes::time() - $time_req) * 1000;
	if ($resp->is_success) {
		print "PASS\t$time_req\t$url\t" . $resp->status_line . "\n";
		$success = 1;
	} else {
		print "FAIL\t$time_req\t$url\t" . $resp->status_line . "\n";
	}
	
	return $success;
}

# Script's main entry point.
sub main {
	# Ensure we have the minimum number of arguments required.
	if (scalar(@ARGV) < 2) {
		print "usage: $0 protocol args\n";
		croak "Failed to provide the minimum number of arguments for the script";
	}

	# Load configuration.
	my $config_file = "$script_dir/config.json";
	croak "Could not find 'config.json' configuration file in script directory"
		unless (-e $config_file);
	$config = load_config($config_file);

	# Get the type of request to make.
	my $proto = lc(shift(@ARGV));
	if ($proto eq 'http') {
		return check_http(@ARGV);
	} else {
		print "Unknown protocol '$proto'. Available protocols are: http\n";
		croak "The provided protocol is not currently supported by the script";
	}

	return 0;
}

main();
__END__;
