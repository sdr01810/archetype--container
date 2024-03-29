#!/bin/sh sourced
## Sourced (only) by the start script in this installation set.
## 
## Defines the run function for this container.
## 

. "$(dirname "$(readlink -f "$0")")"/start.prolog.conf

. "$(dirname "$(readlink -f "$0")")"/provision.prolog.sh

##
## core logic:
##

:

run() { # ...

	if [ $# -eq 0 ] ; then

		sleep_forever
	else
		(exec "$@")
	fi
}

