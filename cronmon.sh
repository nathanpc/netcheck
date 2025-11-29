#!/bin/bash

## cronmon.sh
## Simplifies the monitoring process when called via cron and automatically
## handles log rotation.
##
## Author: Nathan Campos <hi@nathancampos.me>

# Configuration variables.
scriptdir=$(dirname "$0")
logsfile="$scriptdir/logs/$(date '+%Y-%m-%d').log"
dailylink="$scriptdir/daily.log"

# Run monitoring script and append its output to the logs.
perl monitor.pl >> "$logsfile"

if [ ! -e "$dailylink" ] || [ $(readlink "$dailylink") != "$logsfile" ]; then
	ln -sf "$logsfile" "$dailylink"
	echo "Updated daily.log to point to $logsfile"
fi
