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

provision_always="$(dirname "$(readlink -f "$0")")"/provision-always.sh

if [ -e "${provision_always:?}" ] ; then

	"${provision_always:?}" 1>&2
fi

echo 1>&2
echo 1>&2 "STATE: RUNNING"

if [ -t 0 ] && [ $# -eq 0 ] ; then

	su -l
else
	run "$@"
fi

