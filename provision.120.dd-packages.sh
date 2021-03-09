#!/bin/sh
##

. "$(dirname "$(readlink -f "$0")")"/provision.prolog.sh

##
## core logic:
##

dd_packages_needed="${this_script_dpn:?}/${this_script_fbn%.*.sh}".dd-packages.needed

for this_conf_fpn in "${dd_packages_needed:?}".[0-9]*.conf ; do

	[ -f "${this_conf_fpn:?}" ] || continue

	. "${this_conf_fpn:?}"
done

##

ensure_dd_packages_needed

if "${should_clear_cached_artifacts:?}" ; then

	clear_cached_artifacts
fi

