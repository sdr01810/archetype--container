## GNU makefile for this package.
##
## To bootstrap from the archetype, say "make" or "make init".
##
## Then see archetype/container/Makefile.{core,container} for further info.
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

container_image_name          ?= YOUR-CONTAINER-IMAGE-NAME
container_image_version       ?= latest
container_image_base_tag_fq   ?= debian

#^-- make your permanent changes in Makefile.container.conf

endif

ifeq (,$(wildcard Makefile.container))

-include archetype/container/Makefile.core
-include archetype/container/Makefile.container

targets_phony += init init.undo

init :: archetype/container
	@:
	@(echo "To see this list again, issue the command 'make what':" ; \
		echo ; make --no-print-directory what) 2>&1 | \
		$$(which "$${PAGER:-pager}" || echo more)

init.undo ::
	rm -rf archetype/container

archetype/container :
	@:
	@mkdir -p "$(@D)"
	:
	git clone https://github.com/sdr01810/archetype--container.git "$(@)"

${build_output_source_dir}/% : archetype/container/%
	:
	$(call copy_file,$<,$@,${build_output_source_dir_umask})

else

include Makefile.core
include Makefile.container

endif

