#!/bin/bash
##

if [[ -e ./Docker.run.sh ]] ; then

	./Docker.run.sh "$@"
else
	docker run "$@"
fi

