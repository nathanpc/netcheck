#!/usr/bin/env perl

package NetCheck::Check;

use strict;
use warnings;
use autodie;

use POSIX qw(round);
use Carp;
use JSON::PP;
use Time::HiRes;
use Data::Dumper;
use LWP::UserAgent;
use File::Basename;

# Loads the user configuration.
sub load_config {
	my $config_file = dirname(__FILE__) . "/config.json";
	croak "Could not find 'config.json' configuration file in script directory"
		unless (-e $config_file);

	# Open JSON file and read its entire contents.
	open(my $fh, '<:encoding(UTF-8)', $config_file);
	my $contents = join('', <$fh>);
	close($fh);

	return JSON::PP->new->utf8->decode($contents);
}

# Checks HTTP endpoints.
sub check_http {
	my ($url, $timeout) = @_;
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
		timeout => $timeout
	);

	# Perform GET request and time it.
	my $time_start = Time::HiRes::time();
	my $resp = $ua->get($url);
	my $time_req = round((Time::HiRes::time() - $time_start) * 1000);
	if ($resp->is_success) {
		print "$time_start\tPASS\tHTTP\t$time_req\t$url\t" . $resp->status_line . "\n";
		$success = 1;
	} else {
		print "$time_start\tFAIL\tHTTP\t$time_req\t$url\t" . $resp->status_line . "\n";
	}

	return $success;
}

# Perform a check given a protocol.
sub check {
	my ($proto, $url, $timeout) = @_;

	$proto = lc($proto);
	if ($proto eq 'http') {
		return check_http($url, $timeout);
	} else {
		print "Unknown protocol '$proto'. Available protocols are: http\n";
		croak "The provided protocol is not currently supported by the script";
	}

	return 1;
}

# Script's main entry point.
sub main {
	# Ensure we have the minimum number of arguments required.
	if (scalar(@ARGV) < 2) {
		print "usage: $0 protocol args\n";
		croak "Failed to provide the minimum number of arguments for the script";
	}

	# Load configuration and perform a check.
	my $config = load_config();
	return check(@ARGV, $config->{'timeout'});
}

# Run main sub-routine if called as a script.
if (caller) {
	1;
} else {
	__PACKAGE__->main();
}

__END__;
