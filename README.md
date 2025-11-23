# netcheck

A lightweight network service health monitoring system. Allows you to easily
check if your services are up and monitor their performance.

## Setting up

The service itself is almost standalone and only requires the creation of a single
configuration file `config.json` in the same folder as all the scripts. This is an example
of the contents of this configuration file to give you a hint of how to configure it:

```json
{
	"timeout": 10,
	"monitored": [
		{
			"proto": "http",
			"url": "http://nathancampos.me/"
		},
		{
			"proto": "http",
			"url": "https://nathancampos.me/"
		},
		{
			"proto": "http",
			"url": "http://innoveworkshop.com/"
		},
		{
			"proto": "http",
			"url": "https://innoveworkshop.com/"
		}
	]
}
```

The `timeout` value specifies how long the check should wait until it gives up and reports
a site as down, in cases where the connection is successful but the server takes way too
long to respond. If a host is down it fails immediately.

The `monitored` array basically lists all sites that you want to actively monitor using
the `monitor.pl` script. This allows you to quickly automate the monitoring of multiple
hosts.

Each site configuration inside `monitored` should contain a `proto`, specifying which
protocol check the `check.pl` script should use for the site and a `url` that's compatible
with the specified protocol for the check script to query.

## Usage

This service is broken up into separate tools that can be used individually to perform
certain tasks. This architecture ensures that each script/tool more or less adheres to the
[UNIX philosophy](https://en.wikipedia.org/wiki/Unix_philosophy).

### Checking a single host

If all you wish to do is check a single host if it's healthy you should use the `check.pl`
script. This script is responsible for checking a single host and is also the basis for
all other scripts in this system and can be used standalone as follows:

```
$ ./check.pl http 'http://nathancampos.me/'
1763923832.64423	PASS	HTTP	979	http://nathancampos.me/	200 OK
$
```

The output from this tool is a `TAB`-separated with the following fields:

  1. **Timestamp:** Seconds since [Epoch](https://en.wikipedia.org/wiki/Unix_time) with
     the fractional part being milliseconds.
  2. **Status:** Can be `PASS` for success or `FAIL` if something didn't go according to
     plan.
  3. **Protocol:** Which protocol was used to perform the check.
  4. **Latency:** How long, in milliseconds, it took to perform the entire request.
  5. **URL:** Location of the host that was tested.
  6. **Description:** A small description of the response or the reason for a failure.

### Checking multiple hosts

If you've configured the `monitored` array in the `config.json` file, running the
`monitor.pl` script should go through each entry in the configuration and give you the
same output as `check.pl`, although for multiple hosts this time:

```
$ ./monitor.pl
1763924473.77095	PASS	HTTP	987	http://nathancampos.me/	200 OK
1763924474.75834	PASS	HTTP	812	https://nathancampos.me/	200 OK
1763924476.29117	PASS	HTTP	201	http://innoveworkshop.com/	200 OK
1763924476.49261	PASS	HTTP	347	https://innoveworkshop.com/	200 OK
$
```

The output follows the same field specification as `check.pl`, since it's using it
internally to generate its output, and can be easily piped into a file for logging or
passed through other tools for automation purposes, just as
[UNIX intended](https://en.wikipedia.org/wiki/Unix_philosophy).

## License

This application is free software; you may redistribute and/or modify it under the
terms of the [Mozilla Public License 2.0](https://www.mozilla.org/en-US/MPL/2.0/).
