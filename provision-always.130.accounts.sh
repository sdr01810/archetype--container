#!/bin/sh
##

. "$(dirname "$(readlink -f "$0")")"/provision-always.prolog.sh

##
## core logic:
##

accounts_needed="${this_script_dpn:?}/${this_script_fbn%.*.sh}".accounts.needed

accounts_needed="${accounts_needed%%.always.*}.${account_needed##*.always.}"

##

for this_conf_fpn in "${accounts_needed:?}".[0-9]*.conf ; do

	[ -f "${this_conf_fpn:?}" ] || continue

	. "${this_conf_fpn:?}"
done

##

update_os_unix_accounts_needed

