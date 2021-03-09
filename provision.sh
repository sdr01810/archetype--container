#!/bin/sh
## Run provision scripts in order on the invoking host.
##
## Typical uses:
##
##     provision.sh
##

. "$(dirname "$(readlink -f "$0")")"/provision.prolog.sh

##

for x1 in "${this_script_dpn:?}"/provision.[0-9]*.sh ; do

	case "${x1:?}" in (*.functions.sh) continue ;; esac
	
	"${x1:?}"
done

if "${should_ensure_ld_so_cache_is_current:?}" ; then

	ensure_ld_so_cache_is_current
fi

