# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

ifndef wondermake.cbase.template.included

###############################################################################
# Function that executes the template for each user-declared scope that's using the cbase toolchain

define wondermake.cbase.template.loop
  # A first loop stores extra computed variables in the scopes
  $(foreach wondermake.template.scope,$(wondermake), \
    $(if $($(wondermake.template.scope).produced),, \
      $(if $(call wondermake.equals,cbase,$(call wondermake.inherit_unique,$(wondermake.template.scope),toolchain)), \
        $(eval $(value wondermake.cbase.template.first_loop)))))
  
  # A second loop generates the rules
  $(foreach wondermake.template.scope,$(wondermake),\
    $(if $(call wondermake.equals,cbase,$(call wondermake.inherit_unique,$(wondermake.template.scope),toolchain)), \
      $(eval $(value wondermake.cbase.template.second_loop))))
  
  ifneq '' '$(filter template,$(wondermake.verbose))'
    $(info )
    $(info # wondermake cbase end of template execution)
    $(info ###############################################################################)
    $(info ###############################################################################)
    $(info ###############################################################################)
    $(info )
  endif
endef

###############################################################################
# First loop: stores extra computed variables in the scopes

define wondermake.cbase.template.first_loop
  $(wondermake.template.scope).produced := true

  wondermake.default: $(wondermake.template.scope)

  wondermake.template.name := $(or $($(wondermake.template.scope).name),$(wondermake.template.scope))
  $(wondermake.template.scope).name := $(wondermake.template.name)

  # If scope has a name that is different from the scope name
  ifneq '$(wondermake.template.scope)' '$(wondermake.template.name)'
    .PHONY: $(wondermake.template.scope)
    $(wondermake.template.scope): $(wondermake.template.name)
  endif

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

  wondermake.template.scope_dir := $(wondermake.bld_dir)scopes/$(wondermake.template.scope)/
  $(wondermake.template.scope).scope_dir := $(wondermake.template.scope_dir)

  wondermake.template.intermediate_dir := $(wondermake.template.scope_dir)intermediate/
  $(wondermake.template.scope).intermediate_dir := $(wondermake.template.intermediate_dir)

  ifeq 'headers' '$(wondermake.template.type)'
    .PHONY: $(wondermake.template.name)
  else
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

    wondermake.template.obj_files := $(patsubst %,$(wondermake.template.intermediate_dir)%.$(wondermake.template.obj_suffix),$(wondermake.template.mxx_files) $(wondermake.template.cxx_files))
    $(wondermake.template.scope).obj_files := $(wondermake.template.obj_files)

    ifeq 'objects' '$(wondermake.template.type)'
      # No link nor archive step: target is just the list of object files
      wondermake.template.out_files := $(wondermake.template.obj_files)
      .PHONY: $(wondermake.template.name)
      $(wondermake.template.name): $(wondermake.template.out_files)
    else # There is a link or archive step
      wondermake.template.out_files := $(addprefix $(wondermake.staged_install), \
        $(patsubst %,$(call wondermake.inherit_unique,$(wondermake.template.scope),out_file_pattern[$(wondermake.template.type)]),$(wondermake.template.name)))
      # If the platform has any prefix or suffix added to the binary file name
      ifneq '$(wondermake.template.name)' '$(wondermake.template.out_files)'
        .PHONY: $(wondermake.template.name)
        $(wondermake.template.name): $(wondermake.template.out_files)
      endif
      ifeq 'shared_lib' '$(wondermake.template.type)'
        wondermake.template.out_files += $(addprefix $(wondermake.staged_install), \
          $(patsubst %,$(call wondermake.inherit_unique,$(wondermake.template.scope),out_file_pattern[import_lib]),$(wondermake.template.name)))
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
    $(info )
    $(info ###############################################################################)
    $(info ###############################################################################)
    $(info ###############################################################################)
    $(info # wondermake cbase template execution for scope $(wondermake.template.scope))
    $(info )
  endif

  $(eval $(value wondermake.cbase.template.define_vars))
  ifneq '' '$(filter template,$(wondermake.verbose))'
    $(info $(wondermake.cbase.template.define_vars))
  endif

  $(eval $(wondermake.cbase.template.rules_with_evaluated_recipes))
  ifneq '' '$(filter template,$(wondermake.verbose))'
    $(info $(wondermake.cbase.template.rules_with_evaluated_recipes))
  endif

  $(eval $(value wondermake.cbase.template.undefine_vars))
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
  wondermake.template.mxx_d_files := $(patsubst %,$(wondermake.template.intermediate_dir)%.ii.d,$(wondermake.template.external_mxx_files) $(wondermake.template.mxx_files))
  wondermake.template.bmi_suffix := $(call wondermake.inherit_unique,$(wondermake.template.scope),bmi_suffix)

  ifneq 'headers' '$(wondermake.template.type)'
    wondermake.template.cxx_files := $($(wondermake.template.scope).cxx_files)
    wondermake.template.cxx_d_files := $(patsubst %,$(wondermake.template.intermediate_dir)%.ii.d,$(wondermake.template.cxx_files))
    wondermake.template.obj_suffix := $($(wondermake.template.scope).obj_suffix)
    wondermake.template.obj_files := $($(wondermake.template.scope).obj_files)
	wondermake.template.out_files := $($(wondermake.template.scope).out_files)
  endif
endef

###############################################################################
# Define the template rules with recipes that have the temporary loop variables evaluated

define wondermake.cbase.template.rules_with_evaluated_recipes
  $(if $(MAKE_RESTARTS),
    # cpp_command has been executed to bring .ii and .d files up-to-date
    wondermake.clean += $(wondermake.template.scope_dir)cpp_command # explicitly prevent auto-cleaning since we don't call wondermake.write_iif_content_changed.rule

  , # Rules to preprocess c++ source files (only done on the first make phase)

    # Rule to create an output directory
    $(wondermake.template.scope_dir) $(patsubst %,$(wondermake.template.intermediate_dir)%,$(sort $(dir $(wondermake.template.external_mxx_files) $(wondermake.template.mxx_files) $(wondermake.template.cxx_files)))): ; mkdir -p $$@

    # Rule to preprocess a c++ source file (the output directory creation is triggered here)
    $(call wondermake.write_iif_content_changed,$(wondermake.template.scope),cpp_command,$$(call wondermake.cbase.cpp_command,$(wondermake.template.scope)))
    $(foreach src,$(wondermake.template.external_mxx_files) $(wondermake.template.mxx_files) $(wondermake.template.cxx_files),
      $(wondermake.template.intermediate_dir)$(src).ii: \
        $(if $(findstring / /,/ $(src)),$(src),$(wondermake.template.src_dir)$(src)) \
        $(wondermake.bld_dir)wondermake.cbase.configure \
        $(wondermake.template.scope_dir)cpp_command \
        | $(dir $(wondermake.template.intermediate_dir)$(src))
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
  )
  wondermake.dynamically_generated_makefiles += $(wondermake.template.mxx_d_files) $(wondermake.template.cxx_d_files)
  wondermake.clean += $(wondermake.template.mxx_d_files) $(wondermake.template.cxx_d_files)
  wondermake.clean += $(patsubst %,$(wondermake.template.intermediate_dir)%.ii,$(wondermake.template.external_mxx_files) $(wondermake.template.mxx_files) $(wondermake.template.cxx_files))
  wondermake.clean += $(patsubst %,$(wondermake.template.intermediate_dir)%.ii.compile_commands.json,$(wondermake.template.external_mxx_files) $(wondermake.template.mxx_files) $(wondermake.template.cxx_files))
  wondermake.cbase.compile_commands.json += $(patsubst %,$(wondermake.template.intermediate_dir)%.ii.compile_commands.json,$(wondermake.template.external_mxx_files) $(wondermake.template.mxx_files) $(wondermake.template.cxx_files))

  $(if $(strip $(wondermake.template.external_mxx_files) $(wondermake.template.mxx_files)),
    # Rule to precompile a c++ source file to a binary module interface file
    $(call wondermake.write_iif_content_changed,$(wondermake.template.scope),mxx_command,$$(call wondermake.cbase.mxx_command,$(wondermake.template.scope)))
    $(foreach mxx,$(wondermake.template.external_mxx_files) $(wondermake.template.mxx_files),
      $(wondermake.template.intermediate_dir)$(basename $(mxx)).$(wondermake.template.bmi_suffix): \
        $(wondermake.template.intermediate_dir)$(mxx).ii \
        $(wondermake.template.scope_dir)mxx_command \
        | $(wondermake.template.intermediate_dir)$(mxx).ii.d # if .d failed to build, don't continue
			$$(call wondermake.announce,$(wondermake.template.scope),precompile $$<,to $$@)
			$$(eval $$@.evaluable_command = $$($(wondermake.template.scope).mxx_command))
			$$(call $$@.evaluable_command,$$(call wondermake.inherit_append,$(wondermake.template.scope),cxx_flags_unsigned))
			$$(eval undefine $$@.evaluable_command)
      wondermake.clean += $(wondermake.template.intermediate_dir)$(basename $(mxx)).$(wondermake.template.bmi_suffix)
      wondermake.clean += $(wondermake.template.intermediate_dir)$(basename $(mxx)).$(wondermake.template.bmi_suffix).compile_commands.json
      wondermake.cbase.compile_commands.json += $(wondermake.template.intermediate_dir)$(basename $(mxx)).$(wondermake.template.bmi_suffix).compile_commands.json
    )
  )

  $(if $(call wondermake.equals,headers,$(wondermake.template.type)),,
    # Rule to compile a c++ source file to an object file
    $(call wondermake.write_iif_content_changed,$(wondermake.template.scope),cxx_command,$$(call wondermake.cbase.cxx_command,$(wondermake.template.scope)))
    $(wondermake.template.obj_files): %.$(wondermake.template.obj_suffix): %.ii $(wondermake.template.scope_dir)cxx_command | %.ii.d # if .d failed to build, don't continue
		$$(call wondermake.announce,$(wondermake.template.scope),compile $$<,to $$@)
		$$(eval $$@.evaluable_command = $$($(wondermake.template.scope).cxx_command))
		$$(call $$@.evaluable_command,$$(call wondermake.inherit_append,$(wondermake.template.scope),cxx_flags_unsigned))
		$$(eval undefine $$@.evaluable_command)
    wondermake.clean += $(wondermake.template.obj_files)
    wondermake.clean += $(addsuffix .compile_commands.json,$(wondermake.template.obj_files))
    wondermake.cbase.compile_commands.json += $(addsuffix .compile_commands.json,$(wondermake.template.obj_files))

    $(if $(call wondermake.equals,objects,$(wondermake.template.type)),,
      # Rule to trigger relinking or dearchiving when a source file (and hence its derived object file) is removed
      $(call wondermake.write_iif_content_changed,$(wondermake.template.scope),obj_files,$(wondermake.template.obj_files))
      $(wondermake.template.out_files): $(wondermake.template.scope_dir)obj_files

      $(if $(call wondermake.equals,static_lib,$(wondermake.template.type)),
        # Rule to update object files in an archive
        $(call wondermake.write_iif_content_changed,$(wondermake.template.scope),ar_command,$$(call wondermake.cbase.ar_command,$(wondermake.template.scope)))
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
        wondermake.clean += $(wondermake.template.out_files)

      , # Rule to link object files and produce an executable or shared library file
        $(call wondermake.write_iif_content_changed,$(wondermake.template.scope),ld_command,$$(call wondermake.cbase.ld_command,$(wondermake.template.scope)))
        $(firstword $(wondermake.template.out_files)): $(wondermake.template.obj_files) $(wondermake.template.scope_dir)ld_command | $(dir $(wondermake.template.out_files))
			$$(call wondermake.announce,$(wondermake.template.scope),link $$@,from objects $$($(wondermake.template.scope).obj_files))
			$$(eval $$@.evaluable_command = $$($(wondermake.template.scope).ld_command))
			$$(call $$@.evaluable_command,$$(call wondermake.inherit_append,$(wondermake.template.scope),ld_flags_unsigned))
			$$(eval undefine $$@.evaluable_command)
        wondermake.clean += $(wondermake.template.out_files)

        # Library dependencies
        $(eval wondermake.template.deep_deps := \
          $(call wondermake.topologically_sorted_unique_deep_deps,$(wondermake.template.scope),$(call wondermake.equals,static_executable,$(wondermake.template.type))))
        $(firstword $(wondermake.template.out_files)): \
          $(foreach d,$(wondermake.template.deep_deps),$(if $(filter static_lib objects,$($d.type)),$($d.out_files))) | \
          $(foreach d,$(wondermake.template.deep_deps),$(if $(filter shared_lib,$($d.type)),$d))
        # note: we don't use += so we are sure to create an immediate var
        $(wondermake.template.scope).libs := $($(wondermake.template.scope).libs) \
          $(foreach d,$(wondermake.template.deep_deps),$(if $(filter-out headers objects,$($d.type)),$($d.name)))
        $(eval undefine wondermake.template.deep_deps)
      )
    )
  )
endef

###############################################################################
# Define the commands ultimately used by the template recipes

# Command to preprocess a c++ source file
define wondermake.cbase.cpp_command # $1 = scope, $$1 = unsigned flags
	$(or $(call wondermake.user_override,CPP),$(call wondermake.inherit_unique,$1,cpp)) \
	$(call wondermake.inherit_unique,$1,cpp_flags_out_mode) \
	$(call wondermake.inherit_unique,$1,cpp_flags[$(call wondermake.inherit_unique,$1,lang)]) \
	$(call wondermake.inherit_unique,$1,cxx_flags[$(call wondermake.inherit_unique,$1,type)]) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,cpp_define_pattern),$(call wondermake.inherit_append,$1,define)) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,cpp_undefine_pattern),$(call wondermake.inherit_append,$1,undefine)) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,cpp_include_pattern),$(call wondermake.inherit_prepend,$1,include)) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,cpp_include_path_pattern),$(call wondermake.inherit_prepend,$1,include_path)) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,cpp_framework_pattern),$(call wondermake.inherit_prepend,$1,frameworks)) \
	$(call wondermake.cbase.pkg_config_command,$1,--cflags) \
	$(call wondermake.inherit_append,$1,cpp_flags) \
	$$1 \
	$(call wondermake.user_override,CPPFLAGS) \
	$$(abspath $$<)
endef

# Command to precompile a c++ source file to a binary module interface file
define wondermake.cbase.mxx_command # $1 = scope, $$1 = unsigned flags, $(module_map) is a var private to the bmi file rule (see .d files)
	$(or $(call wondermake.user_override,CXX),$(call wondermake.inherit_unique,$1,cxx)) \
	$(call wondermake.inherit_unique,$1,mxx_flags_out_mode) \
	$(call wondermake.inherit_unique,$1,mxx_flags[$(call wondermake.inherit_unique,$1,lang)]) \
	$(call wondermake.inherit_unique,$1,cxx_flags[$(call wondermake.inherit_unique,$1,type)]) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,cxx_module_path_pattern),$(call wondermake.inherit_prepend,$1,module_path)) \
	$$(patsubst %,$(call wondermake.inherit_unique,$1,cxx_module_map_pattern),$(call wondermake.inherit_prepend,$1,module_map) $$(module_map)) \
	$(call wondermake.cbase.pkg_config_command,$1,--cflags-only-other) \
	$(call wondermake.inherit_append,$1,cxx_flags) \
	$$1 \
	$(call wondermake.user_override,CXXFLAGS) \
	$$<
endef

# Command to compile a c++ source file to an object file, $$1 = unsigned flags
define wondermake.cbase.cxx_command # $1 = scope, $(module_map) is a var private to the object file rule (see .d files)
	$(or $(call wondermake.user_override,CXX),$(call wondermake.inherit_unique,$1,cxx)) \
	$(call wondermake.inherit_unique,$1,cxx_flags_out_mode) \
	$(call wondermake.inherit_unique,$1,cxx_flags[$(call wondermake.inherit_unique,$1,lang)]) \
	$(call wondermake.inherit_unique,$1,cxx_flags[$(call wondermake.inherit_unique,$1,type)]) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,cxx_module_path_pattern),$(call wondermake.inherit_prepend,$1,module_path)) \
	$$(patsubst %,$(call wondermake.inherit_unique,$1,cxx_module_map_pattern),$(call wondermake.inherit_prepend,$1,module_map) $$(module_map)) \
	$(call wondermake.cbase.pkg_config_command,$1,--cflags-only-other) \
	$(call wondermake.inherit_append,$1,cxx_flags) \
	$$1 \
	$(call wondermake.user_override,CXXFLAGS) \
	$$<
endef

# Command to link object files and produce an executable or shared library file
define wondermake.cbase.ld_command # $1 = scope, $$1 = unsigned flags
	$(or $(call wondermake.user_override,LD),$(call wondermake.inherit_unique,$1,ld)) \
	$(call wondermake.inherit_unique,$1,ld_flags_out_mode) \
	$(call wondermake.inherit_unique,$1,ld_flags[$(call wondermake.inherit_unique,$1,type)]) \
	$(call wondermake.inherit_append,$1,ld_flags) \
	$$1 \
	$(call wondermake.user_override,LDFLAGS) \
	$$($1.obj_files) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,ld_lib_path_pattern),$(call wondermake.inherit_append,$1,libs_path)) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,ld_lib_pattern),$(call wondermake.inherit_append,$1,libs)) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,ld_framework_pattern),$(call wondermake.inherit_append,$1,frameworks)) \
	$(call wondermake.cbase.pkg_config_command,$1,--libs) \
	$(call wondermake.user_override,LDLIBS)
endef

# Command to update object files in an archive
define wondermake.cbase.ar_command # $1 = scope, $$1 = unsigned flags, $$2 = object files to update
	$(or $(call wondermake.user_override,AR),$(call wondermake.inherit_unique,$1,ar)) \
	$(call wondermake.inherit_append,$1,ar_flags) \
	$$1 \
	$(call wondermake.user_override,ARFLAGS) \
	$(call wondermake.inherit_unique,$1,ar_flags_out_mode) \
	$$2
	$(or $(call wondermake.user_override,RANLIB),$(call wondermake.inherit_unique,$1,ranlib))
endef

# Command to call pkg-config
define wondermake.cbase.pkg_config_command # $1 = scope, $2 = cflags or libs
	$(shell $(or $(call wondermake.user_override,PKG_CONFIG),$(call wondermake.inherit_unique,$1,pkg_config_prog)) $2 \
		$(if $(call wondermake.equals,static_executable,$(call wondermake.inherit_unique,$1,type)),--static) \
		'$(call wondermake.inherit_append,$1,pkg_config)' \
	)
endef

# Command to parse ISO C++ module "export module" keywords in an interface file
define wondermake.cbase.parse_export_module_keyword # $1 = bmi file
	sed -rn 's,^[ 	]*export[ 	]+module[ 	]+([^[ 	;]+)[ 	;],wondermake.module_map[\1] := $1,p' $< >> $@
endef

# Command to parse ISO C++ module "module" keywords in an implementation file
define wondermake.cbase.parse_module_keyword # $1 = obj file
	sed -rn 's,^[ 	]*module[ 	]+([^[ 	;]+)[ 	;],$1: $$$$(wondermake.module_map[\1])\n$1: private module_map = $$(wondermake.module_map[\1]),p' $< >> $@
endef

# Command to parse ISO C++ module "import" keywords in an interface or implementation file
define wondermake.cbase.parse_import_keyword # $1 = targets (obj file, or obj+bmi files)
	sed -rn 's,^[         ]*(export[      ]+|)import[     ]+([^[  ;]+)[   ;],$1: $$$$(wondermake.module_map[\2])\n$1: private module_map += $$(wondermake.module_map[\2]:%=\2=%),p' $< >> $@
endef

###############################################################################
# Compilation database (compile_commands.json)

wondermake.cbase.compile_commands.json := # this is an immediate var
compile_commands.json: $(wondermake.cbase.compile_commands.json)
	$(call wondermake.announce,$@)
	printf '[\n' > $@; \
	cat >> $@; \
	printf ']\n' >> $@
#TODO wondermake.default: compile_commands.json

###############################################################################
endif # ifndef wondermake.cbase.template.included
