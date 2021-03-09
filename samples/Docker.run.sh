#!/bin/sh

docker run \
\
	-v "${CONTAINER_VOLUME_01_DIR:?}":/v/my-container-name/01:ro \
	-v "${CONTAINER_VOLUME_02_DIR:?}":/v/my-container-name/02:rw \
\
	"$@" ;

