## GNU makefile for this package.
##
## See Makefile.{core,container} for usage guidelines.
##
## Place your customizations at the top and/or bottom of the file.
##

ifneq (,$(wildcard Makefile.container))

-include Makefile.core
-include Makefile.container

else

-include archetype/container/Makefile.core
-include archetype/container/Makefile.container

targets_phony += init init.undo

init :: archetype/container
	:
	make --no-print-directory what

init.undo ::
	rm -rf archetype/container

archetype/container :
	@:
	@mkdir -p "$(@D)"
	:
	ln -snf /Work.local/c.sdr/Sandboxes/devops-/project-archetype--container "$@"

${build_output_source_dir}/% : archetype/container/%
	:
	$(call copy_file,$<,$@,${build_output_source_dir_umask})

endif

