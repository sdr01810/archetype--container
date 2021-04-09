#!/bin/sh sourced
## Sourced by each provisioning script in this installation set.
##

. "$(dirname "$(readlink -f "$0")")"/provision.prolog.conf

set -e ; [ -z "${BASH}" ] || set -o pipefail

##

this_script_fpn="$(readlink -f "$0")"

this_script_dpn="$(dirname "${this_script_fpn:?}")"

this_script_fbn="$(basename "${this_script_fpn:?}")"

this_script_name="${this_script_fbn%.*sh}"

##
## from snippet library:
##

append_to_PATH() { # directory_pn

	local d1="${1:?missing value for directory_pn}" ; shift 1

	[ $# -eq 0 ] || return 2

	case "::${PATH}::" in
	*:${d1:?}:*) false ;; *) PATH="${PATH}${PATH:+:}${d1:?}" ;;
	esac
}

prepend_to_PATH() { # directory_pn

	local d1="${1:?missing value for directory_pn}" ; shift 1

	[ $# -eq 0 ] || return 2

	case "::${PATH}::" in
	*:${d1:?}:*) false ;; *) PATH="${d1:?}${PATH:+:}${PATH}" ;;
	esac
}

arguments_quoted() { # ...

	printf '%q\n' "$@"
}

clear_cached_apt_package_lists() { #

	xx :
	xx find /var/lib/apt/lists -mindepth 1 -delete
}

clear_cached_artifacts() { #

	xx :
	xx find artifacts -mindepth 1 -delete
}

configure_env_for_noninteractive_apt() { #

	configure_env_for_noninteractive_dpkg "$@"
}

configure_env_for_noninteractive_dpkg() { #

	# from <https://wiki.debian.org/Multistrap/Environment>:

	export DEBCONF_NONINTERACTIVE_SEEN=true

	export DEBIAN_FRONTEND=noninteractive

	export LC_ALL=C LANGUAGE=C LANG=C
}

ensure_bash_configuration_for_user_spec() {( # user_spec_id

	local user_spec_id="${1:?missing value for user_spec_id}" ; shift 1

	load_os_unix_account_vars_for_user_spec "${user_spec_id:?}"

	ensure_bash_configuration_in_os_unix_home_directory "${this_user_home:?}"
)}

ensure_bash_configuration_in_os_unix_home_directory() { # home_directory_pn

	local home_directory_pn="${1:?missing value for home_directory_pn}" ; shift 1
	local f1

	for f1 in \
		"${home_directory_pn:?}"/.bash_env \
		"${home_directory_pn:?}"/.bash_login \
		"${home_directory_pn:?}"/.bash_logout \
		"${home_directory_pn:?}"/.bash_profile \
	; do
		[ -e "${f1:?}" ] || continue

		xx :
		xx rm -f "${f1:?}"
	done

	for f1 in \
		"${home_directory_pn:?}"/.bashrc \
		"${home_directory_pn:?}"/.profile \
	; do
		[ -e "${f1:?}".overall ] || return 2 # required

		if [ ! -e "${f1:?}".000.init ] ; then

			if [ -e "${f1:?}" ] ; then

				xx :
				xx mv "${f1:?}" "${f1:?}".000.init
			else
				xx :
				xx cp /dev/null "${f1:?}".000.init
			fi
		fi

		xx :
		xx ln -snf "$(basename "${f1:?}".overall)" "${f1:?}"
	done
}

ensure_dd_package_for_spec() {( # dd_package_spec_id

	local dd_package_spec_id="${1:?missing value for dd_package_spec_id}" ; shift 1

	load_dd_package_vars_for_spec "${dd_package_spec_id:?}"

	"${this_dd_package_enabled:?}" || return 0

	if [ ! -e artifacts/"${this_dd_package_artifact_stem:?}".tar.gz ] ; then

		xx :
		xx curl -qsSL --create-dirs -o \
		artifacts/"${this_dd_package_artifact_stem:?}".tar.gz "${this_dd_package_artifact_url:?}"
	fi

	if [ ! -d "${this_dd_package_root_prefix:?}" ] ; then

		xx :
		xx mkdir -p "${this_dd_package_root_prefix:?}"
	fi

	xx :
	xx tar xzf "artifacts/${this_dd_package_artifact_stem:?}".tar.gz -C "${this_dd_package_root_prefix:?}"

	xx :
	xx ln -snf "${this_dd_package_artifact_stem:?}" "${this_dd_package_root_prefix%/}/${this_dd_package_name:?}"
)}

ensure_dd_packages_needed() { #

	local dd_package_spec_id_list="$(get_dd_package_spec_id_list)"
	local dd_package_spec_id

	[ -d artifacts ] || (xx : && xx mkdir -p artifacts)

	for dd_package_spec_id in ${dd_package_spec_id_list} ; do

		ensure_dd_package_for_spec "${dd_package_spec_id:?}"
	done
}

ensure_ld_so_cache_is_current() { #

	local f1 f2

	for f1 in /etc/ld.so.cache ; do

		for f2 in /etc/ld.so.conf /etc/ld.so.conf.d/*.conf ; do

			if [ ! -e "${f1:?}" ] || [ -e "${f2:?}" -a "${f2:?}" -nt "${f1:?}" ] ; then

				if which ldconfig >/dev/null 2>&1 ; then

					xx :
					xx ldconfig
				fi

				break 2
			fi
		done
	done
}

ensure_os_unix_home_directory_for_super_user() { #

	local super_user_home="/root"

	if command -v git >/dev/null ; then

		if [ ! -e "${super_user_home:?}"/.gitconfig ] ; then

			xx :
			xx git config --global user.email root@localhost
			xx git config --global user.name "Administrator"
		fi
	fi
}

ensure_os_unix_home_directory_for_user_spec() {( # user_spec_id

	local user_spec_id="${1:?missing value for user_spec_id}" ; shift 1

	load_os_unix_account_vars_for_user_spec "${user_spec_id:?}"

	local d1

	for d1 in "${this_user_home:?}" "${this_user_home_ref:?}" ; do

		if [ -e "${d1:?}" ] ; then

			xx :
			xx chmod 0700 "${d1:?}"
		else
			xx :
			xx mkdir --mode 0700 -p "${d1:?}"
		fi
	done

	ensure_ssh_configuration_for_user_spec "${user_spec_id:?}"

	ensure_bash_configuration_for_user_spec "${user_spec_id:?}"

	for d1 in "${this_user_home:?}" "${this_user_home_ref:?}" ; do

		ensure_ownership_in_os_unix_home_directory "${d1:?}" "${this_user_name:?}" "${this_user_group_name:?}"
	done
)}

ensure_os_unix_accounts_needed() { #

	local user_spec_id_list="$(get_os_unix_user_spec_id_list)"
	local user_spec_id

	local group_spec_id_list="$(get_os_unix_group_spec_id_list)"
	local group_spec_id

	for group_spec_id in ${group_spec_id_list} ; do

		case "${group_spec_id:?}" in
		(*_user_group)
			# provision user-specific groups w/ the corresponding user
			;;

		(*)
			ensure_os_unix_account_for_group_spec "${group_spec_id:?}"
			;;
		esac
	done

	for user_spec_id in ${user_spec_id_list} ; do

		ensure_os_unix_account_for_user_spec "${user_spec_id:?}"
	done
}

ensure_os_unix_account_for_group_spec() {( # group_spec_id

	local group_spec_id="${1:?missing value for group_spec_id}" ; shift 1

	load_os_unix_account_vars_for_group_spec "${group_spec_id:?}"

	if ! getent group "${this_group_name:?}" >/dev/null ; then

		xx :
		xx addgroup "${this_group_name:?}"
	fi
)}

ensure_os_unix_account_for_user_spec() {( # user_spec_id

	local user_spec_id="${1:?missing value for user_spec_id}" ; shift 1

	load_os_unix_account_vars_for_user_spec "${user_spec_id:?}"

	ensure_os_unix_account_for_group_spec this_user_group

	if ! getent passwd "${this_user_name:?}" >/dev/null ; then

		local this_user_shell_resolved="$(resolve_user_shell_symbol "${this_user_shell:?}")"

		local this_user_shell_spec="${this_user_shell_resolved:+--shell }${this_user_shell_resolved}"

		xx :
		xx adduser \
			--disabled-password \
			\
			--home     "${this_user_home:?}" \
			--ingroup  "${this_user_group_name:?}" \
			\
			--gecos    "${this_user_description:?}" \
			\
			${this_user_shell_spec} \
			\
			"${this_user_name:?}"

		xx :
	fi

	local this_user_group_name

	for this_user_group_name in ${this_user_extra_group_list} ; do

		! [ "${this_user_group_name:?}" = :nil ] || continue

		getent group "${this_user_group_name:?}" >/dev/null || continue

		xx :
		xx adduser "${this_user_name:?}" ${this_user_group_name:?}
	done

	if [ -n "${this_user_home_skeleton_extra}" -a -d "${this_user_home_skeleton_extra}" ] ; then

		local opt_backup="--backup"
		local opt_exclude_template_files="--exclude='*.in'"

		xx :
		xx rsync -a \
			${opt_backup} \
			${opt_exclude_template_files} \
			"${this_user_home_skeleton_extra:?}"/ "${this_user_home:?}"/
	fi

	ensure_os_unix_home_directory_for_user_spec "${user_spec_id:?}"
)}

ensure_ownership_in_os_unix_home_directory() { # home_directory_pn owning_user owning_group

	local home_directory_pn="${1:?missing value for home_directory_pn}" ; shift 1

	local owning_user="${1:?missing value for owning_user}" ; shift 1

	local owning_group="${1:?missing value for owning_group}" ; shift 1

	xx :

	xx chmod 0755 "${home_directory_pn:?}"

	xx chown -R "${owning_user:?}":"${owning_group:?}" "${home_directory_pn:?}"
}

ensure_packages_needed() {

	local packages_needed="${this_script_dpn:?}/${this_script_fbn%.*.sh}".packages.needed

	echo apt:: | install_package_list - "${packages_needed}".[0-9]*
}

ensure_ssh_configuration_for_user_spec() {( # user_spec_id

	local user_spec_id="${1:?missing value for user_spec_id}" ; shift 1

	load_os_unix_account_vars_for_user_spec "${user_spec_id:?}"

	ensure_ssh_configuration_in_directory "${this_user_home:?}"/.ssh "${this_user_name:?}@localhost" ${this_user_ssh_key_type_list} # sic
)}

ensure_ssh_configuration_in_directory() { # ssh_configuration_directory_pn ssh_key_comment [ ssh_key_type ... ]

	local d1="${1:?missing value for ssh_configuration_directory_pn}" ; shift 1

	local ssh_key_comment="${1}" ; [ $# -lt 1 ] || shift 1

	local must_generate_all_specified_ssh_key_types=false

	local f1 b1

	if [ -d "${d1:?}" ] ; then

		xx :
		xx chmod 0700 "${d1:?}"
	else
		xx :
		xx mkdir --mode 0700 -p "${d1:?}"
	fi

	local ssh_key_type
	local ssh_key_type_unresolved

	for ssh_key_type_unresolved in "$@" ; do

		resolve_ssh_key_type_symbol "${ssh_key_type_unresolved}" |

		while read -r ssh_key_type ; do

			[ -n "${ssh_key_type}" ] || continue

			f1="${d1:?}/id_$(echo "${ssh_key_type:?}" | sed -e 's/-/_/g')"

			! [ -s "${f1:?}" -a -s "${f1:?}".pub ] || continue

			xx :
			xx ssh-keygen -t "${ssh_key_type:?}" -f "${f1:?}" -C "${ssh_key_comment}" -N '' || {

				! "${must_generate_all_specified_ssh_key_types:?}" || return 2
			}
		done
	done

	for b1 in authorized_keys config known_hosts ; do

		f1="${d1:?}/${b1:?}"

		! [ -e "${f1:?}" ] || continue

		xx :
		xx cp /dev/null "${f1:?}"
	done

	xx :
	xx find -H "${d1:?}" -mindepth 1 -exec chmod -R ug+rX,o-rx,u+w,o-w {} \;

	for f1 in "${d1:?}"/*.pub ; do

		[ -f "${f1:?}" ] || continue

		xx chmod a+r "${f1:?}"
	done
}

ensure_ssh_server() { #

	install_package openssh-server

	ssh-keygen -A
}

ensure_sudo_without_password_for_os_unix_group() { # group_name

	local group_name="${1:?missing value for group_name}" ; shift 1

	! [ -d /etc/sudoers.d ] ||
	for f1 in /etc/sudoers.d/no-password-needed-for-group-"${group_name:?}" ; do
	(
		xx :

		umask 0337

		echo '%sudo ALL = NOPASSWD: ALL' | xx tee "$f1"

		xx :
		xx chmod 0440 "$f1"

		xx :
		xx sudo_pass_through -E visudo --check --strict
       )
       done
}

get_dd_package_spec_id_list() { #

	get_var_list_unsorted |

	sed -e '/^dd_package_..*_name$/!d ; s/_name$//' |

	sort_var_list
}

get_os_unix_user_spec_id_list() { #

	get_os_unix_account_spec_id_list | (egrep '_user$' || :)
}

get_os_unix_group_spec_id_list() { #

	get_os_unix_account_spec_id_list | (egrep '_group$' || :)
}

get_os_unix_account_spec_id_list() { #

	get_var_list_unsorted |

	sed -e '/_name$/!d ; s/_name$//' | (egrep '_(user|group)$' || :) |

	sort_var_list
}

get_python_version() { # variant

	local python="python${1}"

	"${python:?}" --version 2>&1 |

	sed -e '/^Python *[0-9]/!d ; s/^[^0-9]*//'
}

get_python_version_major() { # variant

	local version="$(get_python_version "$@")"

	local result="${version%%.*}"

	echo "${result}"
}

get_python_version_major_minor() { # variant

	local result="$(get_python_version_major "$@").$(get_python_version_minor "$@")"

	echo "${result}"
}

get_python_version_minor() { # variant

	local version="$(get_python_version "$@")"
	local result

	case "${version}" in
	(*.*)
		result="${version#*.}"

		result="${result%%.*}"
		;;
	('')
		result=
		;;
	(*)
		result="0"
		;;
	esac

	echo "${result}"
}

get_var_list() { #

	get_var_list_unsorted | sort_var_list
}

get_var_list_unsorted() { #

	set | sed -e '/^[_0-9a-zA-Z][_0-9a-zA-Z]*=/!d ; s/=.*//'
}

install_package() { # [ package_spec ... ]

	while [ $# -gt 0 ] ; do

		echo "${1}"
	done |

	install_package_list
}

install_package_list() {( # [ package_list_fpn ... ]

	configure_env_for_noninteractive_apt

	local package_spec_handler_pending=
	local package_spec_remainder_pending_list=

	local package_spec_handler
	local package_spec_remainder

	local package_spec_resolved
	local package_spec

	(interpolate_package_list "$@" ; echo skip::) |

	while read -r package_spec ; do

		[ -n "${package_spec}" ] || continue

		package_spec_resolved="$(resolve_package_spec "${package_spec:?}")"

		: "${package_spec_resolved:?internal error}"

		package_spec_handler="${package_spec_resolved%%:*}"
		package_spec_remainder="${package_spec_resolved#*:}"

		if [ -n "${package_spec_handler_pending}" ] ; then

			if [ "${package_spec_handler_pending:?}" != "${package_spec_handler}" ] ; then

				install_package__spec_handler__"${package_spec_handler_pending:?}" ${package_spec_remainder_pending_list} # sic

				package_spec_handler_pending=
				package_spec_remainder_pending_list=
			fi
		fi

		if install_package__spec_handler__"${package_spec_handler:?}"__can_support_batching ; then

			package_spec_handler_pending="${package_spec_handler:?}"
			package_spec_remainder_pending_list="${package_spec_remainder_pending_list}${package_spec_remainder_pending_list:+ }"
			package_spec_remainder_pending_list="${package_spec_remainder_pending_list}${package_spec_remainder:?}"
		else
			install_package__spec_handler__"${package_spec_handler:?}" "${package_spec_remainder:?}"
		fi
	done
)}

install_package__spec_handler__apt() { # apt_package_spec ...

	local should_install_base=false

	local package_spec_list=
	local package_spec

	for package_spec in "$@" ; do case "${package_spec}" in
	(:|'')
		should_install_base=true
		;;

	(*)
		package_spec_list="${package_spec_list}${package_spec_list:+ }${package_spec:?}"
		;;
	esac;done

	if "${should_install_base:?}" ; then

		install_package__spec_handler__apt__install_base || return
	fi

	if [ -n "${package_spec_list}" ] ; then

		xx :

		xx sudo_pass_through -E apt-get -qq install ${package_spec_list} # sic
	fi
}

install_package__spec_handler__apt__can_support_batching() { #

	true
}

install_package__spec_handler__apt__install_base() { #

	xx :
	xx sudo_pass_through -E apt-get -qq update

	# order is important:

	xx sudo_pass_through -E apt-get -qq install apt-utils

	xx sudo_pass_through -E apt-get -qq install apt dpkg gnupg

	xx sudo_pass_through -E apt-get -qq install apt-transport-https || :

	xx sudo_pass_through -E apt-get -qq install apt-file ca-certificates debconf

	xx sudo_pass_through -E apt-get -qq install software-properties-common
}

install_package__spec_handler__apt_key() { # apt_key_spec

	local apt_key_spec="${1:?missing value for apt_key_spec}" ; shift 1

	[ $# -eq 0 ] || {

		echo 1>&2 "${this_script_name:?}: unexpected argument(s): ${@}"
		return 2
	}

	case "${apt_key_spec}" in
	(:|'')
		install_package__spec_handler__apt_key__install_base || return
		;;

	(*)
		install_package__spec_handler__apt_key__install_1 "${apt_key_spec:?}" || return
		;;
	esac
}

install_package__spec_handler__apt_key__can_support_batching() { #

	false
}

install_package__spec_handler__apt_key__install_1() { # apt_key_spec

	local apt_key_spec="${1:?missing value for apt_key_spec}" ; shift 1

	local apt_key_spec_type="${apt_key_spec%% *}" apt_key_spec_remainder="${apt_key_spec#* }"

	apt_key_spec_remainder="$(
	install_package__spec_handler__apt_key__interpolate "${apt_key_spec_remainder}")" || return

	: "${apt_key_spec_remainder:?internal error}"

	case "${apt_key_spec_type}" in
	(file)
		xx :
		xx sudo_pass_through -E apt-key add "${apt_key_spec_remainder}"
		;;

	(gpg)
		xx :
		xx sudo_pass_through -E apt-key adv ${apt_key_spec_remainder} # sic
		;;

	(url)
		xx :
		xx curl -qsSL "${apt_key_spec_remainder:?}" |
		xx sudo_pass_through -E apt-key add - 2>&1 | egrep -v 'Warning: apt-key\b'
		;;

	('')
		echo 1>&2 "${this_script_name:?}: empty apt key spec"
		return 2
		;;

	(*)
		echo 1>&2 "${this_script_name:?}: unrecognized apt key spec: ${apt_key_spec:?}"
		return 2
		;;
	esac
}

install_package__spec_handler__apt_key__install_base() { #

	: # TODO: install keys to match the basic set of apt repositories
}

install_package__spec_handler__apt_key__interpolate() { # ...

	install_package__spec_handler__apt_repo__interpolate "$@"
}

install_package__spec_handler__apt_repo() { # apt_repo_spec

	local apt_repo_spec="${1:?missing value for apt_repo_spec}" ; shift 1

	[ $# -eq 0 ] || {

		echo 1>&2 "${this_script_name:?}: unexpected argument(s): ${@}"
		return 2
	}

	case "${apt_repo_spec}" in
	(:|'')
		install_package__spec_handler__apt_repo__install_base || return
		;;

	(*)
		install_package__spec_handler__apt_repo__install_1 "${apt_repo_spec:?}" || return
		;;
	esac

	xx :
	xx sudo_pass_through -E apt-get update
}

install_package__spec_handler__apt_repo__can_support_batching() { #

	false
}

install_package__spec_handler__apt_repo__install_1() { # apt_repo_spec

	local apt_repo_spec="${1:?missing value for apt_repo_spec}" ; shift 1

	local apt_repo_spec_type="${apt_repo_spec%% *}" apt_repo_spec_remainder="${apt_repo_spec#* }"

	case "${apt_repo_spec_type}" in
	(deb|deb-src)
		apt_repo_spec_remainder="$(
		install_package__spec_handler__apt_repo__interpolate "${apt_repo_spec_remainder}")" || return

		: "${apt_repo_spec_remainder:?internal error}"

		xx :
		xx sudo_pass_through -E apt-add-repository "${apt_repo_spec_type:?} ${apt_repo_spec_remainder:?}"
		;;
	
	('')
		echo 1>&2 "${this_script_name:?}: empty apt repo spec"
		return 2
		;;

	(*)
		unset apt_repo_spec_type apt_repo_spec_remainder

		xx :
		xx sudo_pass_through -E apt-add-repository "${apt_repo_spec:?}"
		;;
	esac |

	if "${should_show_notes_from_apt_repository_when_adding:?}" ; then

		cat
	else
		cat > /dev/null
	fi
}

install_package__spec_handler__apt_repo__install_base() { #

	: # TODO: install a basic set of generally useful apt repositories
}

install_package__spec_handler__apt_repo__interpolate() { # ...

	while [ $# -gt 0 ] ; do

		echo "${1}" | sed \
			-e 's#\$(os_release ARCH)#'"$(              os_release ARCH ||              echo os_release_ARCH_UNKNOWN)"'#g' \
			-e 's#\$(os_release ID)#'"$(                os_release ID ||                echo os_release_ID_UNKNOWN)"'#g' \
			-e 's#\$(os_release NAME)#'"$(              os_release NAME ||              echo os_release_NAME_UNKNOWN)"'#g' \
			-e 's#\$(os_release VERSION_CODENAME)#'"$(  os_release VERSION_CODENAME ||  echo os_release VERSION_CODENAME_UNKNOWN)"'#g' \
			-e 's#\$(os_release VERSION_ID)#'"$(        os_release VERSION_ID ||        echo os_release_VERSION_ID_UNKNOWN)"'#g' \
			;

			#^-- each interpolated expression expands to exactly one word

		shift
	done
}

install_package__spec_handler__python_variant() { # variant pip_package_spec ...

	local variant="${1}" ; shift 1

	local python="python${variant}" pip="pip${variant}"

	local should_install_base=false

	local package_spec_list=
	local package_spec

	for package_spec in "$@" ; do case "${package_spec}" in
	(:|'')
		should_install_base=true
		;;

	(*)
		package_spec_list="${package_spec_list}${package_spec_list:+ }${package_spec}"
		;;
	esac;done

	if "${should_install_base:?}" ; then

		install_package__spec_handler__python_variant__install_base "${variant}" || return
	fi

	if [ -n "${package_spec_list}" ] ; then

		local pip_install_options="-qqq"
		local pip_install_command="${pip} install ${pip_install_options}"

		xx :
		xx sudo_pass_through -E -H ${pip_install_command} ${package_spec_list}
	fi
}

install_package__spec_handler__python_variant__can_support_batching() { # variant

	true
}

install_package__spec_handler__python_variant__install_base() { # variant

	local variant_default="2" # pythonic convention

	local variant="${1:-${variant_default}}" ; shift 1

	local VERSION_ID_MIN=0.0 VERSION_ID_MAX=10000.10000

	local os_release_VERSION_ID="$(os_release VERSION_ID || echo ${VERSION_ID_MAX:?})"

	local os_release_ID="$(os_release ID || echo unknown)"

	case "${variant}" in
	(2)
		if [ "${os_release_ID:?}" = debian ] && [ "${os_release_VERSION_ID%%.*}" -lt 10 ] ; then

			variant=
		else
		if [ "${os_release_ID:?}" = ubuntu ] && [ "${os_release_VERSION_ID%%.*}" -lt 20 ] ; then

			variant=
		fi;fi
		;;
	esac

	local package_spec_python="python${variant}" package_spec_python_distutils=

	case "${variant}" in
	(3)
		if [ "${os_release_ID:?}" = debian ] && [ "${os_release_VERSION_ID%%.*}" -lt 10 ] ; then

			package_spec_python_distutils= # provided by python package
		else
		if [ "${os_release_ID:?}" = ubuntu ] && [ "${os_release_VERSION_ID%%.*}" -lt 18 ] ; then

			package_spec_python_distutils= # provided by python package
		else
			package_spec_python_distutils="python${variant}-distutils"
		fi;fi
		;;
	esac

	install_package__spec_handler__apt ${package_spec_python:?} ${package_spec_python_distutils} # sic

	##

	local python="python${variant}"
	local python_version_major="$(get_python_version_major "${variant}")"
	local python_version_minor="$(get_python_version_minor "${variant}")"

	local pip_installer_url_prefix=https://bootstrap.pypa.io/pip/
	local pip_installer_url

	if [ "${python_version_major:?}" -lt 2 ] ; then

		: # pip is not available
	else
	if [ "${python_version_major:?}" -eq 2 -a "${python_version_minor:?}" -lt 6 ] ; then

		: # pip is not available
	else
	if [ "${python_version_major:?}" -eq 2 ] ; then

		pip_installer_url="${pip_installer_url_prefix:?}${python_version_major:?}.${python_version_minor:?}/"get-pip.py
	else
	if [ "${python_version_major:?}" -eq 3 -a "${python_version_minor:?}" -lt 6 ] ; then

		pip_installer_url="${pip_installer_url_prefix:?}${python_version_major:?}.${python_version_minor:?}/"get-pip.py
	else
		pip_installer_url="${pip_installer_url_prefix:?}"get-pip.py
	fi;fi
	fi;fi

	local pip="pip${variant}"

	if hash "${pip:?}" >/dev/null 2>&- ; then

		:
	else
	if [ -n "${pip_installer_url}" ] ; then

		local pip_install_options="-qqq"
		local pip_module_install_command="pip install ${pip_install_options}"

		xx :
		xx curl -qsSL "${pip_installer_url:?}" |
		xx sudo_pass_through -E -H "${python}" - ${pip_install_options}

		xx :
		xx sudo_pass_through -E -H "${python}" -m ${pip_module_install_command} --upgrade pip
	fi;fi
}

install_package__spec_handler__python() { # pip_package_spec ...

	install_package__spec_handler__python_variant '' "$@"
}

install_package__spec_handler__python__can_support_batching() { #

	install_package__spec_handler__python_variant__can_support_batching ''
}

install_package__spec_handler__python2() { # pip_package_spec ...

	install_package__spec_handler__python_variant 2 "$@"
}

install_package__spec_handler__python2__can_support_batching() { #

	install_package__spec_handler__python_variant__can_support_batching 2
}

install_package__spec_handler__python3() { # pip_package_spec ...

	install_package__spec_handler__python_variant 3 "$@"
}

install_package__spec_handler__python3__can_support_batching() { #

	install_package__spec_handler__python_variant__can_support_batching 3
}

install_package__spec_handler__skip() { # ...

	case "$*" in
	(:|'')
		install_package__spec_handler__skip__install_base || return
		;;

	(*)
		install_package__spec_handler__skip__install_1 "$@" || return
		;;
	esac
}

install_package__spec_handler__skip__can_support_batching() { #

	false
}

install_package__spec_handler__skip__install_1() { # ...

	: # by design: do nothing
}

install_package__spec_handler__skip__install_base() { #

	: # by design: do nothing
}

install_package__spec_handler__update_alternatives() { # ...

	case "$*" in
	(:|'')
		install_package__spec_handler__update_alternatives__install_base || return
		;;

	(*)
		install_package__spec_handler__update_alternatives__install_1 "$@" || return
		;;
	esac
}

install_package__spec_handler__update_alternatives__can_support_batching() { #

	false
}

install_package__spec_handler__update_alternatives__install_1() { # ...

	xx :
	xx sudo_pass_through -E update-alternatives $* # sic
}

install_package__spec_handler__update_alternatives__install_base() { #

	install_package__spec_handler__apt__install_base

	#^-- update-alternatives(1) is part of dpkg
}

interpolate_package_list() { # [ package_list_fpn ... ]

	local package_list_fpn

	if [ $# -eq 0 ] ; then

		cat
	else
		interpolate_package_list__impl_each "$@"
	fi |

	(egrep -v '^\s*(#|$)' || :) |

	sed -e 's/#.*$//' |

	cat -s
}

interpolate_package_list__impl_each() { # [ package_list_fpn ... ]

	local package_list_fpn

	for package_list_fpn in "$@" ; do

		case "${package_list_fpn:?}" in
		(*.list.sh)
			(. "${package_list_fpn:?}") || return
			;;

		(*|'')
			cat "${package_list_fpn:?}"
			;;
		esac
	done
}

list_all_known_apt_packages() { #

	apt-cache pkgnames
}

load_dd_package_vars_for_spec() { # dd_package_spec_id

	local dd_package_spec_id="${1:?missing value for dd_package_spec_id}" ; shift 1
	local dq='"'

	eval "this_dd_package_artifact_stem=${dq}\${${dd_package_spec_id}_artifact_stem}${dq}"

	eval "this_dd_package_artifact_url=${dq}\${${dd_package_spec_id}_artifact_url}${dq}"

	eval "this_dd_package_enabled=${dq}\${${dd_package_spec_id}_enabled}${dq}"

	eval "this_dd_package_name=${dq}\${${dd_package_spec_id}_name}${dq}"

	eval "this_dd_package_root_prefix=${dq}\${${dd_package_spec_id}_root_prefix}${dq}"

	##

	: "${this_dd_package_name:?incomplete dd package spec (missing name): ${dd_package_spec_id:?}}"

	: "${this_dd_package_artifact_stem:?incomplete dd package spec (missing artifact_stem): ${dd_package_spec_id:?}}"

	#^-- FIXME: align format and style of package spec error messages across spec types

	case "${this_dd_package_enabled}" in
	false)
		this_dd_package_enabled=false
		;;

	*|'')
		this_dd_package_enabled=true
		;;
	esac

	: "${this_dd_package_root_prefix:=${PROVISIONING_ROOT_PREFIX%/}/opt}"
}

load_os_unix_account_vars_for_group_spec() { # group_spec_id

	local group_spec_id="${1:?missing value for group_spec_id}" ; shift 1
	local dq='"'

	eval "this_group_name=${dq}\${${group_spec_id}_name}${dq}"

	: "${this_group_name:?missing value for name; group_spec_id: ${group_spec_id:?}}"
}

load_os_unix_account_vars_for_user_spec() { # user_spec_id

	local user_spec_id="${1:?missing value for user_spec_id}" ; shift 1
	local dq='"'

	eval "this_user_description=${dq}\${${user_spec_id}_description}${dq}"

	eval "this_user_group_name=${dq}\${${user_spec_id}_group_name}${dq}"

	eval "this_user_extra_group_list=${dq}\${${user_spec_id}_extra_group_list}${dq}"

	eval "this_user_home=${dq}\${${user_spec_id}_home}${dq}"

	eval "this_user_home_ref=${dq}\${${user_spec_id}_home_ref}${dq}"

	eval "this_user_home_skeleton_extra=${dq}\${${user_spec_id}_home_skeleton_extra}${dq}"

	eval "this_user_name=${dq}\${${user_spec_id}_name}${dq}"

	eval "this_user_shell=${dq}\${${user_spec_id}_shell}${dq}"

	eval "this_user_ssh_key_type_list=${dq}\${${user_spec_id}_ssh_key_type_list}${dq}"

	: "${this_user_name:?missing value for name; user_spec_id: ${user_spec_id:?}}"

	: "${this_user_description:=${this_user_name:?} account}"
	: "${this_user_group_name:=${this_user_name:?}}"
	: "${this_user_extra_group_list:=}"
	: "${this_user_home:=/home/${this_user_name:?}}"
	: "${this_user_home_skeleton_extra:=home-skeleton}"
	: "${this_user_shell:=:system-picks-user-shell}"
	: "${this_user_ssh_key_type_list:=:all}"

	: "${this_user_home_ref:=${this_user_home:?}.ref}"
}

os_release() {( # variable_name ...

	set -e ; . /etc/os-release || return

	local ARCH="$(dpkg --print-architecture 2>&-)"

	while [ $# -gt 0 ] ; do

		if [ -n "${1}" ] ; then

			(eval "echo \${${1}:?}") 2>&- || return
		else
			echo ""
		fi

		shift
	done
)}

printenv_sorted() { #

	xx printenv | xx env LC_ALL=C sort
}

resolve_package_spec() { # package_spec

	local package_spec="${1:?missing value for package_spec}" ; shift 1

	local package_spec_handler= package_spec_remainder="${package_spec:?}"

	case "${package_spec}" in (:*|*:*|*:)

		package_spec_handler="${package_spec%%:*}"

		package_spec_remainder="$(echo "${package_spec#*:}" | sed -e 's#^ *##')"
		;; 
	esac

	case "${package_spec_handler}" in
	(apt|apt-key|apt-repo|python|python2|python3|skip|update-alternatives)

		package_spec_handler="$(
		echo "${package_spec_handler:?}" | sed -e 's#[^a-z0-9]#_#g')"
		;;

	('')
		package_spec_handler="apt"
		;;

	(*)
		echo 1>&2 "${this_script_name:?}: unrecognized installation handler in package spec: ${package_spec:?}"
		return 2
		;;
	esac

	: "${package_spec_remainder:=:}" # thus /handler:/ --> /handler::/

	local result="${package_spec_handler:?}:${package_spec_remainder:?}"

	echo "${result:?}"
}

resolve_ssh_key_type_symbol() { # ssh_key_type_symbol

	local ssh_key_type_symbol="${1:?missing value for ssh_key_type_symbol}" ; shift 1

	local should_emit_sk_variants_of_ssh_key_types=false

	case "${ssh_key_type_symbol:?}" in
	:all|:all-types|:all-key-types|:all-ssh-key-types)

		echo dsa
		echo ecdsa
		echo ed25519
		echo rsa

		if "${should_emit_sk_variants_of_ssh_key_types:?}" ; then

			echo ecdsa-sk
			echo ed25519-sk
		fi
		;;

	:nil)

		echo
		;;

	:*)

		echo 1>&2 "${this_script_name:?}: unrecognized ssh key type symbol: '${ssh_key_type_symbol:?}'"
		return 2
		;;

	*)

		echo "${1:?}"
		;;
	esac
}

resolve_user_shell_symbol() { # user_shell_symbol

	local user_shell_symbol="${1:?missing value for user_shell_symbol}" ; shift 1

	case "${user_shell_symbol:?}" in
	:system-picks|:system-picks-user-shell)

		echo
		;;

	:nil)

		echo
		;;

	:*)

		echo 1>&2 "${this_script_name:?}: unrecognized user shell symbol: '${user_shell_symbol:?}'"
		return 2
		;;

	*)

		echo "${user_shell_symbol:?}"
		;;
	esac
}

sleep_forever() { #

	while true ; do

		sleep 3600
	done
}

sort_var_list() { #

	sort_var_list_by '_sort_order'
}

sort_var_list_by() { # ordering_suffix

	local dq='"'

	local v1 v1_sorting_order

	local sorting_field_separator='='

	local sorting_order_after_numbers='@'

	local ordering_suffix="${1:?missing value for ordering_suffix}" ; shift 1

	while read -r v1 ; do

		eval "local v1_sorting_order=${dq}\${${v1}${ordering_suffix}:-${sorting_order_after_numbers}}${dq}"

		echo "${v1_sorting_order}${sorting_field_separator}${v1}"
	done |

	sort -t"${sorting_field_separator}" -n |

	sed -e "s/^[^${sorting_field_separator}]*=//"
}

sudo_pass_through() { # ...

	local options=

	while [ $# -gt 0 ] ; do
	case "${1}" in
	--)
		shift 1
		;;
	-E|-H|--preserve-env=PATH)
		options="${options}${options:+ }${1}"
		shift 1
		;;
	-*|-)
		(unset error ; : "${error:?unsupported sudo(8) option: ${1}}")
		return
		;;
	*)
		break
		;;
	esac;done

	if [ "$(id -u)" -ne 0 ] ; then

		sudo ${options} "$@"
	else
		"$@"
	fi
}

sync_os_unix_home_directory_with_ref_for_user_spec() {( # user_spec_id

	local user_spec_id="${1:?missing value for user_spec_id}" ; shift 1

	load_os_unix_account_vars_for_user_spec "${user_spec_id:?}"

	xx :
	xx rsync -a -u "${this_user_home_ref:?}"/ "${this_user_home:?}"/

	ensure_ownership_in_os_unix_home_directory "${this_user_home:?}" "${this_user_name:?}" "${this_user_group_name:?}"

	xx :
	xx rsync -a -u "${this_user_home:?}"/ "${this_user_home_ref:?}"/

	ensure_ownership_in_os_unix_home_directory "${this_user_home_ref:?}" "${this_user_name:?}" "${this_user_group_name:?}"
)}

sync_ref_with_os_unix_home_directory_for_user_spec() {( # user_spec_id

	local user_spec_id="${1:?missing value for user_spec_id}" ; shift 1

	load_os_unix_account_vars_for_user_spec "${user_spec_id:?}"

	xx :
	xx rsync -a -u "${this_user_home:?}"/ "${this_user_home_ref:?}"/

	ensure_ownership_in_os_unix_home_directory "${this_user_home_ref:?}" "${this_user_name:?}" "${this_user_group_name:?}"

	xx :
	xx rsync -a -u "${this_user_home_ref:?}"/ "${this_user_home:?}"/

	ensure_ownership_in_os_unix_home_directory "${this_user_home:?}" "${this_user_name:?}" "${this_user_group_name:?}"
)}

update_os_unix_home_directory_for_user_spec() {( # user_spec_id

	local user_spec_id="${1:?missing value for user_spec_id}" ; shift 1

	load_os_unix_account_vars_for_user_spec "${user_spec_id:?}"

	sync_os_unix_home_directory_with_ref_for_user_spec "${user_spec_id:?}"
)}

update_os_unix_accounts_needed() { #

	local user_spec_id_list="$(get_os_unix_user_spec_id_list)"
	local user_spec_id

	local group_spec_id_list="$(get_os_unix_group_spec_id_list)"
	local group_spec_id

	for group_spec_id in ${group_spec_id_list} ; do

		case "${group_spec_id:?}" in
		(*_user_group)
			# provision user-specific groups w/ the corresponding user
			;;

		(*)
			update_os_unix_account_for_group_spec "${group_spec_id:?}"
			;;
		esac
	done

	for user_spec_id in ${user_spec_id_list} ; do

		update_os_unix_account_for_user_spec "${user_spec_id:?}"
	done
}

update_os_unix_account_for_group_spec() {( # group_spec_id

	local group_spec_id="${1:?missing value for group_spec_id}" ; shift 1

	load_os_unix_account_vars_for_group_spec "${group_spec_id:?}"

	: # nothing to do (yet)
)}

update_os_unix_account_for_user_spec() {( # user_spec_id

	local user_spec_id="${1:?missing value for user_spec_id}" ; shift 1

	load_os_unix_account_vars_for_user_spec "${user_spec_id:?}"

	update_os_unix_account_for_group_spec "${user_spec_id:?}"_group

	update_os_unix_home_directory_for_user_spec "${user_spec_id:?}"
)}

xx() { # ...

	echo 1>&2 "+" "$@"
	"$@"
}

##
## core logic:
##

configure_env_for_noninteractive_apt

umask 022

