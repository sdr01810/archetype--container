#!/bin/bash
##

set -e

set -o pipefail

PATH=$(dirname "${BASH_SOURCE:?}")/host/bin${PATH:+:}${PATH}

##
## from snippet library:
##

xx() { # ...

	echo 1>&2 "${PS4:-+}" "$@"

	"$@"
}

##
## core logic:
## 

image_tag=
image_build_args=()

while [[ $# -gt 0 ]] ; do case "${1}" in
(--tag)
	image_build_args+=( "${1}" "${2}" )

	image_tag="${2}"

	shift 2 || :
	;;

(*|'')
	image_build_args+=( "${1}" )

	shift 1
	;;
esac;done

: "${image_tag:?missing value for image tag}"

##

xx :
xx docker image build "${image_build_args[@]}"

[[ -e ./Docker.first-run.sh ]] || exit 0

##

xx :
xx docker image tag "${image_tag:?}" "${image_tag:?}"--cp00

c1=$(xx : && xx ./Docker.first-run.sh --detach "${image_tag:?}" | tee Docker.first-run.id)

xx :
xx docker-logs-follow-until 'STATE: RUNNING' ${c1:?}

xx :
xx docker commit -m 'First run steady-state' ${c1:?} "${image_tag:?}"--cp01

xx :
xx docker image tag "${image_tag:?}"--cp01 "${image_tag:?}"

xx :
xx docker stop ${c1:?} >/dev/null

xx :
xx docker rm ${c1:?}

