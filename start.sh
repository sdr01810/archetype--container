#!/bin/sh
## Entry point for the container.
##

handle_exit() {

	handle_exit__impl_hook ||

	handle_exit__impl_base ||

	return
}

handle_exit__impl_hook() {

	return
}

handle_exit__impl_base() {

	local rc=$?

	echo 1>&2
	echo 1>&2 "STATE: FINISHED; EXIT CODE = ${rc}"
	echo 1>&2
}

. "$(dirname "$(readlink -f "$0")")"/start.prolog.sh

trap handle_exit EXIT

##

echo 1>&2
echo 1>&2 "STATE: STARTING"

"$(dirname "$(readlink -f "$0")")"/provision-always.sh 1>&2

echo 1>&2
echo 1>&2 "STATE: RUNNING"

if [ $# -gt 0 ] ; then

	echo 1>&2

	"$@"
else
if [ -t 0 ] ; then

	echo 1>&2

	su -l
else
	run
fi;fi

