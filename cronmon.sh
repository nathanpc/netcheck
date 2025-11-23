#!/bin/bash

## cronmon.sh
## Simplifies the monitoring process when called via cron and automatically handles log
## rotation.
##
## Author: Nathan Campos <hi@nathancampos.me>

# Configuration variables.
logsdir="$(dirname "$0")/logs"
logsfile="$logsdir/$(date '+%Y-%m-%d').log"

# Run monitoring script and append its output to the logs.
perl monitor.pl >> "$logsfile"
