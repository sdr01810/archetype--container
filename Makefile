## GNU makefile for this package.
##
## See Makefile.{core,container} for behavior contract.
##
## There should be no need to edit this file. Instead, introduce your own
## customizations in one of the following files, which would become part
## of your own project, and are reserved for that purpose:
##
##   Makefile.core.conf
##   Makefile.core.local
##
##   Makefile.container.conf
##   Makefile.container.local
##

ifeq (,$(wildcard Makefile.container.conf))

container_image_name          ?= MY-CONTAINER-IMAGE-NAME
container_image_version       ?= latest
container_image_base_tag_fq   ?= debian

#^-- make your permanent changes in Makefile.container.conf

endif

include Makefile.core
include Makefile.container

