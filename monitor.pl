#!/usr/bin/env perl

package NetCheck::Monitor;

use strict;
use warnings;
use autodie;

use Data::Dumper;
use File::Basename;

require "./check.pl";

# Checks all monitored sites.
sub check_monitored {
	my ($timeout, @monitored) = @_;
	my $failures = 0;

	# Go through each monitored site.
	foreach my $site (@monitored) {
		$failures += NetCheck::Check::check($site->{'proto'}, $site->{'url'},
			$timeout);
	}

	return $failures;
}

# Script's main entry point.
sub main {
	# Load configuration and check monitored sites.
	my $config = NetCheck::Check::load_config();
	return check_monitored($config->{'timeout'}, @{$config->{'monitored'}});
}

# Run main sub-routine if called as a script.
if (caller) {
	1;
} else {
	__PACKAGE__->main();
}

__END__;
