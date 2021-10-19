#!/bin/bash
##

set -e

set -o pipefail

##
## core logic:
##

for x1 in $(egrep -v '^\s*(#|$)' Docker.image.base.tag.list || :) ; do

	x2=${x1#*/} ; x2=${x2//:/-}

	(
		for g1 in "${@:-check}" ; do

			xx :
			xx make container_image_base_tag_fq="${x1:?}" "${g1:?}"
		done

		echo 1>&2
		echo 1>&2 "MAKE FOR BASE TAG COMPLETE; EXIT CODE: $?"

	) |& tee .sb.make.$(timestamp-as-file-name).base-tag.${x2:?}.tty
done

xx :
xx make source
#^-- ensures primary base tag is current

echo 1>&2
echo 1>&2 "MAKE FOR EACH BASE TAG COMPLETE; EXIT CODE: $?"

