#!/bin/sh
##

. "$(dirname "$(readlink -f "$0")")"/provision.prolog.sh

##
## core logic:
##

accounts_needed="${this_script_dpn:?}/${this_script_fbn%.*.sh}".accounts.needed

for this_conf_fpn in "${accounts_needed:?}".[0-9]*.conf ; do

	[ -f "${this_conf_fpn:?}" ] || continue

	. "${this_conf_fpn:?}"
done

##

ensure_os_unix_accounts_needed

if "${should_ensure_sudo_without_password_for_os_unix_group_sudo:?}" ; then

	ensure_sudo_without_password_for_os_unix_group sudo
fi

