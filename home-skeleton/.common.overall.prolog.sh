#!/bin/sh sourced
## Provides helper functions for the user's overall sh and/or bash setup.
##
## +-------+-----------------------------+---------------------------------------+
## | Shell |          Session            | Sourced                               |
## |       +-------------+---------------+                                       |
## |       | Login       | Interactive   | By                                    |
## +-------+-------------+---------------+---------------------------------------+
## | sh    | N           | N             | (nada)                                |
## +-------+-------------+---------------+---------------------------------------+
## | sh    | N           | Y             | (nada)                                |
## +-------+-------------+---------------+---------------------------------------+
## | sh    | Y           | N             | ~/.profile.overall                    |
## +-------+-------------+---------------+---------------------------------------+
## | sh    | Y           | Y             | ~/.profile.overall                    |
## +-------+-------------+---------------+---------------------------------------+
## | bash  | N           | N             | (nada)                                |
## +-------+-------------+---------------+---------------------------------------+
## | bash  | N           | Y             | ~/.bashrc.overall                     |
## +-------+-------------+---------------+---------------------------------------+
## | bash  | Y           | N             | ~/.bashrc.overall                     |
## +-------+-------------+---------------+---------------------------------------+
## | bash  | Y           | Y             | ~/.bashrc.overall                     |
## +-------+-------------+---------------+---------------------------------------+
##

: "${USER:=$(id -un)}" ; export USER

: "${HOME:?missing value for HOME}" ; export HOME

. "${HOME:?}"/.common.overall.prolog.conf # must exist

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

#^-- FIXME: duplicated code
#^-- FIXME: include "common.prolog.sh" instead when that is supported

