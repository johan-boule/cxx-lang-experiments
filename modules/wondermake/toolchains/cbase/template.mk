# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

ifndef wondermake.cbase.template.included

###############################################################################
# Function that executes the template for each user-declared scope that's using the cbase toolchain

define wondermake.cbase.template.loop
  wondermake.template.scopes_to_process := $(strip \
    $(foreach wondermake.template.scope,$(wondermake), \
      $(if $(call wondermake.equals,cbase,$(call wondermake.inherit_unique,$(wondermake.template.scope),toolchain)), \
        $(if $($(wondermake.template.scope).processed),, \
          $(wondermake.template.scope) \
    ))))

  ifneq '' '$(filter template,$(wondermake.verbose))'
    $(info )
    $(info ###############################################################################)
    $(info ###############################################################################)
    $(info ###############################################################################)
    $(info # wondermake cbase begin of template execution)
    $(info # scopes: $(wondermake.template.scopes_to_process))
    $(info )
  endif

  # A first loop stores extra computed variables in the scopes
  $(foreach wondermake.template.scope,$(wondermake.template.scopes_to_process), \
    $(if $(filter template,$(wondermake.verbose)), \
      $(info ) \
      $(info ###############################################################################) \
      $(info ###############################################################################) \
      $(info ###############################################################################) \
      $(info # wondermake cbase template execution) \
      $(info # first loop) \
      $(info # scope: $(wondermake.template.scope)) \
      $(info ) \
      $(info $(wondermake.cbase.template.first_loop)) \
    ) \
    $(eval $(value wondermake.cbase.template.first_loop)) \
  )

  # A second loop generates the rules
  $(foreach wondermake.template.scope,$(wondermake.template.scopes_to_process),\
    $(if $(filter template,$(wondermake.verbose)), \
      $(info ) \
      $(info ###############################################################################) \
      $(info ###############################################################################) \
      $(info ###############################################################################) \
      $(info # wondermake cbase template execution) \
      $(info # second loop) \
      $(info # scope: $(wondermake.template.scope)) \
      $(info ) \
    ) \
    $(eval $(value wondermake.cbase.template.second_loop)) \
  )

  $(wondermake.cbase.compile_commands.json): %.compile_commands.json: %

  ifneq '' '$(filter template,$(wondermake.verbose))'
    $(info )
    $(info # wondermake cbase end of template execution)
    $(info # scopes: $(wondermake.template.scopes_to_process))
    $(info ###############################################################################)
    $(info ###############################################################################)
    $(info ###############################################################################)
    $(info )
  endif

  undefine wondermake.template.scopes_to_process
endef

wondermake.flatten_path = $1
wondermake.flatten_path = $(subst ..,_,$(subst /,!,$1))

###############################################################################
# First loop: stores extra computed variables in the scopes

define wondermake.cbase.template.first_loop
  wondermake.template.name := $(or $($(wondermake.template.scope).name),$(wondermake.template.scope))
  $(wondermake.template.scope).name := $(wondermake.template.name)

  wondermake.template.type := $(call wondermake.inherit_unique,$(wondermake.template.scope),type)
  wondermake.template.type := $(or $(call wondermake.inherit_unique,$(wondermake.template.scope),default_type[$(wondermake.template.type)]),$(wondermake.template.type))
  $(wondermake.template.scope).type := $(wondermake.template.type)

  wondermake.template.src_dir := $(call wondermake.inherit_unique,$(wondermake.template.scope),src_dir)
  $(wondermake.template.scope).src_dir := $(wondermake.template.src_dir)

  wondermake.template.mxx_files := $(patsubst $(wondermake.template.src_dir)%,%, \
    $(shell find $(addprefix $(wondermake.template.src_dir),$($(wondermake.template.scope).src)) \
      -name '' \
      $(patsubst %,-o -name '*.%', \
      $(or \
        $(call wondermake.inherit_unique,$(wondermake.template.scope),mxx_suffix) \
        $(call wondermake.inherit_unique,$(wondermake.template.scope),mxx_suffix[$(call wondermake.inherit_unique,$(wondermake.template.scope),lang)])))))
  $(wondermake.template.scope).mxx_files := $(wondermake.template.mxx_files)

  wondermake.template.scope_dir := $(wondermake.scopes_dir)$(wondermake.template.scope)/
  $(wondermake.template.scope).scope_dir := $(wondermake.template.scope_dir)

  wondermake.template.intermediate_dir := $(wondermake.template.scope_dir)intermediate/
  $(wondermake.template.scope).intermediate_dir := $(wondermake.template.intermediate_dir)

  ifneq 'headers' '$(wondermake.template.type)'
    wondermake.template.cxx_files := $(patsubst $(wondermake.template.src_dir)%,%, \
      $(shell find $(addprefix $(wondermake.template.src_dir),$($(wondermake.template.scope).src)) \
        -name '' \
        $(patsubst %,-o -name '*.%', \
          $(or \
            $(call wondermake.inherit_unique,$(wondermake.template.scope),cxx_suffix) \
            $(call wondermake.inherit_unique,$(wondermake.template.scope),cxx_suffix[$(call wondermake.inherit_unique,$(wondermake.template.scope),lang)])))))
    $(wondermake.template.scope).cxx_files := $(wondermake.template.cxx_files)

    wondermake.template.obj_suffix := $(call wondermake.inherit_unique,$(wondermake.template.scope),obj_suffix)
    $(wondermake.template.scope).obj_suffix := $(wondermake.template.obj_suffix)

    wondermake.template.obj_files := $(patsubst %,$(wondermake.template.intermediate_dir)%.$(wondermake.template.obj_suffix),$(call wondermake.flatten_path,$(wondermake.template.mxx_files) $(wondermake.template.cxx_files)))
    $(wondermake.template.scope).obj_files := $(wondermake.template.obj_files)

    ifeq 'objects' '$(wondermake.template.type)'
      # No link nor archive step: target is just the list of object files
      wondermake.template.out_files := $(wondermake.template.obj_files)
    else # There is a link or archive step
      wondermake.template.out_files := \
        $(patsubst %,$(call wondermake.inherit_unique,$(wondermake.template.scope),out_file_pattern[$(wondermake.template.type)]),$(wondermake.template.name))
      ifeq 'shared_lib' '$(wondermake.template.type)'
        # Some platform has an import lib as a by-product
        wondermake.template.out_files += \
          $(patsubst %,$(call wondermake.inherit_unique,$(wondermake.template.scope),out_file_pattern[import_lib]),$(wondermake.template.name))
      endif
    endif
    $(wondermake.template.scope).out_files := $(wondermake.template.out_files)

    undefine wondermake.template.cxx_files
    undefine wondermake.template.obj_suffix
    undefine wondermake.template.obj_files
    undefine wondermake.template.out_files
  endif

  undefine wondermake.template.name
  undefine wondermake.template.type
  undefine wondermake.template.src_dir
  undefine wondermake.template.mxx_files
  undefine wondermake.template.scope_dir
  undefine wondermake.template.intermediate_dir
endef

###############################################################################
# Second loop: generates the rules

define wondermake.cbase.template.second_loop
  ifneq '' '$(filter template,$(wondermake.verbose))'
    $(info $(wondermake.cbase.template.define_vars))
  endif
  $(eval $(value wondermake.cbase.template.define_vars))

  ifneq '' '$(filter template,$(wondermake.verbose))'
    $(info $(wondermake.cbase.template.rules_with_evaluated_recipes))
  endif
  $(eval $(wondermake.cbase.template.rules_with_evaluated_recipes))

  $(eval $(value wondermake.cbase.template.undefine_vars))

  $(wondermake.template.scope).processed := true
endef

###############################################################################
# Undefine the temporary variables used in the template execution loop

define wondermake.cbase.template.undefine_vars
  undefine wondermake.template.name
  undefine wondermake.template.type
  undefine wondermake.template.src_dir
  undefine wondermake.template.scope_dir
  undefine wondermake.template.external_mxx_files
  undefine wondermake.template.mxx_files
  undefine wondermake.template.cxx_files
  undefine wondermake.template.intermediate_dir
  undefine wondermake.template.mxx_d_files
  undefine wondermake.template.cxx_d_files
  undefine wondermake.template.bmi_suffix
  undefine wondermake.template.obj_suffix
  undefine wondermake.template.obj_files
  undefine wondermake.template.out_files
endef

###############################################################################
# Define the temporary variables used in the template execution loop

define wondermake.cbase.template.define_vars
  wondermake.template.name := $($(wondermake.template.scope).name)
  wondermake.template.type := $($(wondermake.template.scope).type)

  wondermake.template.src_dir := $($(wondermake.template.scope).src_dir)
  wondermake.template.external_mxx_files := $(call wondermake.inherit_prepend,$(wondermake.template.scope),external_modules_path)
  ifneq '' '$(wondermake.template.external_mxx_files)'
    wondermake.template.external_mxx_files := \
      $(shell cd $(wondermake.template.src_dir) && find $(wondermake.template.external_mxx_files) \
        -name '' \
          $(patsubst %,-o -name '*.%', \
            $(or \
              $(call wondermake.inherit_unique,$(wondermake.template.scope),mxx_suffix) \
              $(call wondermake.inherit_unique,$(wondermake.template.scope),mxx_suffix[$(call wondermake.inherit_unique,$(wondermake.template.scope),lang)]))))
  endif

  wondermake.template.mxx_files := $($(wondermake.template.scope).mxx_files)
  wondermake.template.scope_dir := $($(wondermake.template.scope).scope_dir)
  wondermake.template.intermediate_dir := $($(wondermake.template.scope).intermediate_dir)
  wondermake.template.mxx_d_files := $(patsubst %,$(wondermake.template.intermediate_dir)%.ii.d, \
    $(call wondermake.flatten_path, $(wondermake.template.external_mxx_files) $(wondermake.template.mxx_files)))
  wondermake.template.bmi_suffix := $(call wondermake.inherit_unique,$(wondermake.template.scope),bmi_suffix)

  ifneq 'headers' '$(wondermake.template.type)'
    wondermake.template.cxx_files := $($(wondermake.template.scope).cxx_files)
    wondermake.template.cxx_d_files := $(patsubst %,$(wondermake.template.intermediate_dir)%.ii.d, \
	  $(call wondermake.flatten_path,$(wondermake.template.cxx_files)))
    wondermake.template.obj_suffix := $($(wondermake.template.scope).obj_suffix)
    wondermake.template.obj_files := $($(wondermake.template.scope).obj_files)
	wondermake.template.out_files := $($(wondermake.template.scope).out_files)
  endif
endef

###############################################################################
# Define the template rules with recipes that have the temporary loop variables evaluated

define wondermake.cbase.template.rules_with_evaluated_recipes
  wondermake.default: $(wondermake.template.scope)
  $(if $(call wondermake.equals,$(wondermake.template.scope),$(wondermake.template.out_files)),,
    .PHONY: $(wondermake.template.scope)
    $(wondermake.template.scope): $(wondermake.template.out_files)
  )

  $(if $(MAKE_RESTARTS),, # only do this on the first make phase
    # Rules to preprocess c++ source files (only done on the first make phase)

    # Rule to create an output directory
    $(wondermake.template.scope_dir) \
    $(wondermake.template.intermediate_dir) \
    $(patsubst %,$(wondermake.template.intermediate_dir)%, \
      $(sort $(dir $(wondermake.template.external_mxx_files) $(wondermake.template.mxx_files) $(wondermake.template.cxx_files)))) \
    : ; mkdir -p $$@

    # Rule to preprocess a c++ source file (the output directory creation is triggered here)
    $(call wondermake.write_iif_content_changed_scope_var,$(wondermake.template.scope),cpp_command,$$(call wondermake.cbase.cpp_command,$(wondermake.template.scope)))
    $(foreach src,$(wondermake.template.external_mxx_files) $(wondermake.template.mxx_files) $(wondermake.template.cxx_files),
      $(wondermake.template.intermediate_dir)$(call wondermake.flatten_path,$(src)).ii: \
        $(if $(findstring / /,/ $(src)),$(src),$(wondermake.template.src_dir)$(src)) \
        $(wondermake.bld_dir)wondermake.cbase.configure \
        $(wondermake.template.scope_dir)cpp_command \
        | $(dir $(wondermake.template.intermediate_dir)$(call wondermake.flatten_path,$(src)))
			$$(call wondermake.announce,$(wondermake.template.scope),preprocess $$<,to $$@)
			$$(eval $$@.evaluable_command = $$($(wondermake.template.scope).cpp_command))
			$$(call $$@.evaluable_command,$$(call wondermake.inherit_append,$(wondermake.template.scope),cpp_flags_unsigned))
			$$(eval undefine $$@.evaluable_command)
    )

    $(if $(wondermake.template.mxx_d_files),
      # Rule to parse ISO C++ module keywords in an interface file
      $(wondermake.template.mxx_d_files): %.ii.d: %.ii
		$$(call wondermake.announce,$(wondermake.template.scope),extract-deps $$<,to $$@)
		$$(call wondermake.cbase.parse_export_module_keyword,$$(basename $$*).$(wondermake.template.bmi_suffix))
		$$(call wondermake.cbase.parse_import_keyword,$$*.$(wondermake.template.obj_suffix) $$(basename $$*).$(wondermake.template.bmi_suffix))
    )

    $(if $(wondermake.template.cxx_d_files),
      # Rule to parse ISO C++ module keywords in an implementation file
      $(wondermake.template.cxx_d_files): %.ii.d: %.ii
		$$(call wondermake.announce,$(wondermake.template.scope),extract-deps $$<,to $$@)
		$$(call wondermake.cbase.parse_module_keyword,$$*.$(wondermake.template.obj_suffix))
		$$(call wondermake.cbase.parse_import_keyword,$$*.$(wondermake.template.obj_suffix))
    )
    wondermake.clean += $(wondermake.template.mxx_d_files) $(wondermake.template.cxx_d_files)
    wondermake.clean += $(patsubst %,$(wondermake.template.intermediate_dir)%.ii,$(call wondermake.flatten_path,$(wondermake.template.external_mxx_files) $(wondermake.template.mxx_files) $(wondermake.template.cxx_files)))
    wondermake.clean += $(patsubst %,$(wondermake.template.intermediate_dir)%.ii.compile_commands.json,$(call wondermake.flatten_path,$(wondermake.template.external_mxx_files) $(wondermake.template.mxx_files) $(wondermake.template.cxx_files)))
  )
  wondermake.cbase.compile_commands += $(wondermake.template.scope_dir)cpp_command
  wondermake.cbase.compile_commands.json += $(patsubst %,$(wondermake.template.intermediate_dir)%.ii.compile_commands.json,$(call wondermake.flatten_path,$(wondermake.template.external_mxx_files) $(wondermake.template.mxx_files) $(wondermake.template.cxx_files)))
  wondermake.dynamically_generated_makefiles += $(wondermake.template.mxx_d_files) $(wondermake.template.cxx_d_files)

  $(if $(wondermake.template.external_mxx_files)$(wondermake.template.mxx_files),
    # Rule to precompile a c++ source file to a binary module interface file
    $(call wondermake.write_iif_content_changed_scope_var,$(wondermake.template.scope),mxx_command,$$(call wondermake.cbase.mxx_command,$(wondermake.template.scope)))
    $(foreach mxx,$(wondermake.template.external_mxx_files) $(wondermake.template.mxx_files),
      $(wondermake.template.intermediate_dir)$(basename $(call wondermake.flatten_path,$(mxx))).$(wondermake.template.bmi_suffix): \
        $(wondermake.template.intermediate_dir)$(call wondermake.flatten_path,$(mxx)).ii \
        $(wondermake.template.scope_dir)mxx_command \
        | $(wondermake.template.intermediate_dir)$(call wondermake.flatten_path,$(mxx)).ii.d # if .d failed to build, don't continue
			$$(call wondermake.announce,$(wondermake.template.scope),precompile $$<,to $$@)
			$$(eval $$@.evaluable_command = $$($(wondermake.template.scope).mxx_command))
			$$(call $$@.evaluable_command,$$(call wondermake.inherit_append,$(wondermake.template.scope),cxx_flags_unsigned))
			$$(eval undefine $$@.evaluable_command)
      $(if $(MAKE_RESTARTS),, # only do this on the first make phase
        wondermake.clean += $(wondermake.template.intermediate_dir)$(call wondermake.flatten_path,$(basename $(mxx))).$(wondermake.template.bmi_suffix)
        wondermake.clean += $(wondermake.template.intermediate_dir)$(call wondermake.flatten_path,$(basename $(mxx))).$(wondermake.template.bmi_suffix).compile_commands.json
      )
      wondermake.cbase.compile_commands += $(wondermake.template.scope_dir)mxx_command
      wondermake.cbase.compile_commands.json += $(wondermake.template.intermediate_dir)$(call wondermake.flatten_path,$(basename $(mxx))).$(wondermake.template.bmi_suffix).compile_commands.json
    )
  )

  $(call wondermake.write_iif_content_changed_scope_var,$(wondermake.template.scope),type,$(wondermake.template.type))
  $(if $(call wondermake.equals,headers,$(wondermake.template.type)),,
    # Rule to compile a c++ source file to an object file
    $(call wondermake.write_iif_content_changed_scope_var,$(wondermake.template.scope),cxx_command,$$(call wondermake.cbase.cxx_command,$(wondermake.template.scope)))
    $(wondermake.template.obj_files): %.$(wondermake.template.obj_suffix): %.ii $(wondermake.template.scope_dir)cxx_command | %.ii.d # if .d failed to build, don't continue
		$$(call wondermake.announce,$(wondermake.template.scope),compile $$<,to $$@)
		$$(eval $$@.evaluable_command = $$($(wondermake.template.scope).cxx_command))
		$$(call $$@.evaluable_command,$$(call wondermake.inherit_append,$(wondermake.template.scope),cxx_flags_unsigned))
		$$(eval undefine $$@.evaluable_command)
    $(if $(MAKE_RESTARTS),, # only do this on the first make phase
      wondermake.clean += $(wondermake.template.obj_files)
      wondermake.clean += $(addsuffix .compile_commands.json,$(wondermake.template.obj_files))
    )
    wondermake.cbase.compile_commands += $(wondermake.template.scope_dir)cxx_command
    wondermake.cbase.compile_commands.json += $(addsuffix .compile_commands.json,$(wondermake.template.obj_files))

    $(if $(call wondermake.equals,objects,$(wondermake.template.type)),,
      # There is a link or archive step

      # Rule to trigger relinking or dearchiving when a source file (and hence its derived object file) is removed
      $(call wondermake.write_iif_content_changed_scope_var,$(wondermake.template.scope),obj_files,$(wondermake.template.obj_files))
      $(wondermake.template.out_files): $(wondermake.template.scope_dir)obj_files

      $(if $(call wondermake.equals,static_lib,$(wondermake.template.type)),
        # Static lib archive

        # Rule to update object files in an archive
        $(call wondermake.write_iif_content_changed_scope_var,$(wondermake.template.scope),ar_command,$$(call wondermake.cbase.ar_command,$(wondermake.template.scope)))
        $(wondermake.template.out_files): $(wondermake.template.obj_files) $(wondermake.template.scope_dir)ar_command | $(dir $(wondermake.template.out_files))
			$$(eval $$@.object_files := \
				$$(filter $$($(wondermake.template.scope).obj_files), \
					$$(if $$(filter $(wondermake.template.scope_dir)ar_command $(wondermake.template.scope_dir)obj_files,$$?), \
						$$+, \
						$$? \
					) \
				) \
			)
			$$(call wondermake.announce,$(wondermake.template.scope),archive $$@,from objects $$($$@.object_files))
			$$(eval $$@.evaluable_command = $$($(wondermake.template.scope).ar_command))
			$$(call $$@.evaluable_command,$$(call wondermake.inherit_append,$(wondermake.template.scope),ar_flags_unsigned),$$($$@.object_files))
			$$(eval undefine $$@.evaluable_command)
			$$(eval undefine $$@.object_files)

      , # Shared lib or loadable module

        # Rule to link object files and produce an executable or shared library file
        $(call wondermake.write_iif_content_changed_scope_var,$(wondermake.template.scope),ld_command,$$(call wondermake.cbase.ld_command,$(wondermake.template.scope)))
        $(firstword $(wondermake.template.out_files)): $(wondermake.template.obj_files) $(wondermake.template.scope_dir)ld_command | $(dir $(wondermake.template.out_files))
			$$(call wondermake.announce,$(wondermake.template.scope),link $$@,from objects $$($(wondermake.template.scope).obj_files))
			$$(eval $$@.evaluable_command = $$($(wondermake.template.scope).ld_command))
			$$(call $$@.evaluable_command,$$(call wondermake.inherit_append,$(wondermake.template.scope),ld_flags_unsigned))
			$$(eval undefine $$@.evaluable_command)

        # Multi-output rule
        $(if $(call wondermake.equals,1,$(words $(wondermake.template.out_files))),,
          # Some platform has an import lib as a by-product
          $(wordlist 1,$(words $(wondermake.template.out_files)),$(wondermake.template.out_files)): $(firstword $(wondermake.template.out_files))
        )

        # Library dependencies
        # Note: If a dep's type just changed to shared_lib, we need to relink. Hence why we add the dep's type file as a prerequisite.
        # Note: For the libs var assignement, we don't use += so we are sure to create an immediate var if the var didn't exist.
        $(eval wondermake.template.deep_deps := \
          $(call wondermake.topologically_sorted_unique_deep_deps,$(wondermake.template.scope),$(call wondermake.equals,static_executable,$(wondermake.template.type))))
        $(firstword $(wondermake.template.out_files)): \
          $(foreach d,$(wondermake.template.deep_deps),$(if $(filter static_lib objects,$($d.type)),$($d.out_files))) \
          $(foreach d,$(wondermake.template.deep_deps),$(if $(filter shared_lib,$($d.type)),$($d.scope_dir)type)) | \
          $(foreach d,$(wondermake.template.deep_deps),$(if $(filter shared_lib,$($d.type)),$d))
        $(wondermake.template.scope).libs := $($(wondermake.template.scope).libs) \
          $(foreach d,$(wondermake.template.deep_deps),$(if $(filter-out headers objects,$($d.type)),$($d.name)))
        $(eval undefine wondermake.template.deep_deps)
      )

      $(if $(MAKE_RESTARTS),, # only do this on the first make phase
        wondermake.clean += $(wondermake.template.out_files)
      )
    )
  )
endef

###############################################################################
endif # ifndef wondermake.cbase.template.included
