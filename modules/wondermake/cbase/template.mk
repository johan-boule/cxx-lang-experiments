# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

ifndef wondermake.cbase.template.included

###############################################################################
# Define the template

define wondermake.template
  ifneq '' '$(filter template,$(wondermake.verbose))'
    $(info )
    $(info ###############################################################################)
    $(info ###############################################################################)
    $(info ###############################################################################)
    $(info # Template execution for scope $(wondermake.template.scope))
    $(info )
  endif

  $(eval $(value wondermake.template.define_vars))
  ifneq '' '$(filter template,$(wondermake.verbose))'
    $(info $(wondermake.template.define_vars))
  endif

  $(eval $(wondermake.template.rules_with_evaluated_recipes))
  ifneq '' '$(filter template,$(wondermake.verbose))'
    $(info $(wondermake.template.rules_with_evaluated_recipes))
  endif

  $(eval $(value wondermake.template.undefine_vars))
endef

###############################################################################
# Undefine the temporary variables used in the template execution loop

define wondermake.template.undefine_vars
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
  undefine wondermake.template.binary_file
endef

###############################################################################
# Define the temporary variables used in the template execution loop

define wondermake.template.define_vars
  wondermake.default: $(wondermake.template.scope)

  ifdef $(wondermake.template.scope).name
    wondermake.template.name := $($(wondermake.template.scope).name)
    # If scope has explicitely defined a name that is different from the scope name
    ifneq '$(wondermake.template.scope)' '$(wondermake.template.name)'
      .PHONY: $(wondermake.template.scope)
      $(wondermake.template.scope): $(wondermake.template.name)
    endif
  else
    wondermake.template.name := $(wondermake.template.scope)
    $(wondermake.template.scope).name := $(wondermake.template.scope)
  endif

  wondermake.template.type := $(call wondermake.inherit_unique,$(wondermake.template.scope),type)
  wondermake.template.src_dir := $(call wondermake.inherit_unique,$(wondermake.template.scope),src_dir)
  wondermake.template.scope_dir := $(wondermake.bld_dir)scopes/$(wondermake.template.scope)/

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

  wondermake.template.mxx_files := $(patsubst $(wondermake.template.src_dir)%,%, \
	$(shell find $(addprefix $(wondermake.template.src_dir),$($(wondermake.template.scope).src)) \
		-name '' \
		$(patsubst %,-o -name '*.%', \
			$(or \
				$(call wondermake.inherit_unique,$(wondermake.template.scope),mxx_suffix) \
				$(call wondermake.inherit_unique,$(wondermake.template.scope),mxx_suffix[$(call wondermake.inherit_unique,$(wondermake.template.scope),lang)])))))
  wondermake.template.intermediate_dir := $(wondermake.template.scope_dir)intermediate/
  wondermake.template.mxx_d_files := $(patsubst %,$(wondermake.template.intermediate_dir)%.ii.d,$(wondermake.template.external_mxx_files) $(wondermake.template.mxx_files))
  wondermake.template.bmi_suffix := $(call wondermake.inherit_unique,$(wondermake.template.scope),bmi_suffix)

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
    wondermake.template.cxx_d_files := $(patsubst %,$(wondermake.template.intermediate_dir)%.ii.d,$(wondermake.template.cxx_files))
    wondermake.template.obj_suffix := $(call wondermake.inherit_unique,$(wondermake.template.scope),obj_suffix)
    wondermake.template.obj_files := $(patsubst %,$(wondermake.template.intermediate_dir)%.$(wondermake.template.obj_suffix),$(wondermake.template.mxx_files) $(wondermake.template.cxx_files))
    ifeq 'objects' '$(wondermake.template.type)'
	  # No link nor archive step: target is just the list of object files
      $(wondermake.template.scope).out := $(wondermake.template.obj_files)
      .PHONY: $(wondermake.template.name)
      $(wondermake.template.name): $($(wondermake.template.scope).out)
    else # There is a link or archive step
      wondermake.template.binary_file := $(addprefix $(wondermake.staged_install), \
		$(patsubst %,$(call wondermake.inherit_unique,$(wondermake.template.scope),binary_file_pattern[$(wondermake.template.type)]),$(wondermake.template.name)))
      $(wondermake.template.scope).out := $(wondermake.template.binary_file)
      # If the platform has any prefix or suffix added to the binary file name
      ifneq '$(wondermake.template.name)' '$(wondermake.template.binary_file)'
        .PHONY: $(wondermake.template.name)
        $(wondermake.template.name): $($(wondermake.template.scope).out)
      endif
    endif
  endif
endef

###############################################################################
# Define the template rules with recipes that have the temporary loop variables evaluated

define wondermake.template.rules_with_evaluated_recipes

  # Rules to preprocess c++ source files
  ifdef MAKE_RESTARTS # cpp_command has been executed to bring .ii and .d files up-to-date
    wondermake.clean += $(wondermake.template.scope_dir)cpp_command # explicitly prevent auto-cleaning since we don't call wondermake.write_iif_content_changed.rule
  else # only do this on the first make phase
    # Rule to create an output directory
    $(wondermake.template.scope_dir) $(patsubst %,$(wondermake.template.intermediate_dir)%,$(sort $(dir $(wondermake.template.external_mxx_files) $(wondermake.template.mxx_files) $(wondermake.template.cxx_files)))): ; mkdir -p $$@

    # Rule to preprocess a c++ source file (the output directory creation is triggered here)
    $(call wondermake.write_iif_content_changed,$(wondermake.template.scope),cpp_command,$$(call wondermake.cbase.cpp_command,$(wondermake.template.scope)))
    $(foreach src,$(wondermake.template.external_mxx_files) $(wondermake.template.mxx_files) $(wondermake.template.cxx_files), \
      $(wondermake.newline) $(wondermake.template.intermediate_dir)$(src).ii: \
		$(if $(findstring / /,/ $(src)),$(src),$(wondermake.template.src_dir)$(src)) \
		$(wondermake.bld_dir)wondermake.cbase.configure \
		$(wondermake.template.scope_dir)cpp_command \
		| $(dir $(wondermake.template.intermediate_dir)$(src)) \
      $(wondermake.newline)		$$(call wondermake.announce,$(wondermake.template.scope),preprocess $$<,to $$@) \
      $(wondermake.newline)		$$(eval $$@.evaluated_command := $$($(wondermake.template.scope).cpp_command)) \
      $(wondermake.newline)		$$($$@.evaluated_command) \
      $(wondermake.newline)		$$(eval undefine $$@.evaluated_command) \
      $(wondermake.newline) \
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
  endif
  wondermake.dynamically_generated_makefiles += $(wondermake.template.mxx_d_files) $(wondermake.template.cxx_d_files)
  wondermake.clean += $(wondermake.template.mxx_d_files) $(wondermake.template.cxx_d_files)
  wondermake.clean += $(patsubst %,$(wondermake.template.intermediate_dir)%.ii,$(wondermake.template.external_mxx_files) $(wondermake.template.mxx_files) $(wondermake.template.cxx_files))
  wondermake.clean += $(patsubst %,$(wondermake.template.intermediate_dir)%.ii.compile_commands.json,$(wondermake.template.external_mxx_files) $(wondermake.template.mxx_files) $(wondermake.template.cxx_files))
  wondermake.compile_commands.json += $(patsubst %,$(wondermake.template.intermediate_dir)%.ii.compile_commands.json,$(wondermake.template.external_mxx_files) $(wondermake.template.mxx_files) $(wondermake.template.cxx_files))

  $(if $(strip $(wondermake.template.external_mxx_files) $(wondermake.template.mxx_files)),
    # Rule to precompile a c++ source file to a binary module interface file
    $(call wondermake.write_iif_content_changed,$(wondermake.template.scope),mxx_command,$$(call wondermake.cbase.mxx_command,$(wondermake.template.scope)))
    $(foreach mxx,$(wondermake.template.external_mxx_files) $(wondermake.template.mxx_files),
      $(wondermake.template.intermediate_dir)$(basename $(mxx)).$(wondermake.template.bmi_suffix): \
        $(wondermake.template.intermediate_dir)$(mxx).ii \
        $(wondermake.template.scope_dir)mxx_command \
        | $(wondermake.template.intermediate_dir)$(mxx).ii.d # if .d failed to build, don't continue
			$$(call wondermake.announce,$(wondermake.template.scope),precompile $$<,to $$@)
			$$(eval $$@.evaluated_command := $$($(wondermake.template.scope).mxx_command))
			$$($$@.evaluated_command)
			$$(eval undefine $$@.evaluated_command)
      wondermake.clean += $(wondermake.template.intermediate_dir)$(basename $(mxx)).$(wondermake.template.bmi_suffix)
      wondermake.clean += $(wondermake.template.intermediate_dir)$(basename $(mxx)).$(wondermake.template.bmi_suffix).compile_commands.json
      wondermake.compile_commands.json += $(wondermake.template.intermediate_dir)$(basename $(mxx)).$(wondermake.template.bmi_suffix).compile_commands.json
    )
  )

  $(if $(call wondermake.equals,headers,$(wondermake.template.type)),,
    # Rule to compile a c++ source file to an object file
    $(call wondermake.write_iif_content_changed,$(wondermake.template.scope),cxx_command,$$(call wondermake.cbase.cxx_command,$(wondermake.template.scope)))
    $(wondermake.template.obj_files): %.$(wondermake.template.obj_suffix): %.ii $(wondermake.template.scope_dir)cxx_command | %.ii.d # if .d failed to build, don't continue
		$$(call wondermake.announce,$(wondermake.template.scope),compile $$<,to $$@)
		$$(eval $$@.evaluated_command := $$($(wondermake.template.scope).cxx_command))
		$$($$@.evaluated_command)
		$$(eval undefine $$@.evaluated_command)
    wondermake.clean += $(wondermake.template.obj_files)
    wondermake.clean += $(addsuffix .compile_commands.json,$(wondermake.template.obj_files))
    wondermake.compile_commands.json += $(addsuffix .compile_commands.json,$(wondermake.template.obj_files))

    $(if $(call wondermake.equals,objects,$(wondermake.template.type)),,
      # XXX maybe allow static by default? static_lib or lib and wondermake.cbase.default_lib_type is static_lib
      $(if $(call wondermake.equals,static_lib,$(wondermake.template.type)),
        # TODO static archive
      , # else, there is a link step
        # Rule to link object files and produce an executable or shared library file
        $(call wondermake.write_iif_content_changed,$(wondermake.template.scope),ld_command,$$(call wondermake.cbase.ld_command,$(wondermake.template.scope)))
        $(wondermake.template.binary_file): $(wondermake.template.obj_files) $(wondermake.template.scope_dir)ld_command | $(dir $(wondermake.template.binary_file))
			$$(call wondermake.announce,$(wondermake.template.scope),link $$@,from objects $$(filter-out $(wondermake.template.scope_dir)ld_command $(wondermake.template.scope_dir)obj_files,$$+))
			$$(eval $$@.evaluated_command := $$($(wondermake.template.scope).ld_command))
			$$($$@.evaluated_command)
			$$(eval undefine $$@.evaluated_command)
        wondermake.clean += $(wondermake.template.binary_file)

        # Rule to trigger relinking when a source file (and hence its derived object file) is removed
        $(call wondermake.write_iif_content_changed,$(wondermake.template.scope),obj_files,$(wondermake.template.obj_files))
        $(wondermake.template.binary_file): $(wondermake.template.scope_dir)obj_files

        # Library dependencies
        # XXX maybe allow static by default? static_executable or executable and wondermake.cbase.default_executable_type is static_executable
        $(if $(filter-out headers objects static_lib,$(wondermake.template.type)),
          $(eval wondermake.template.deep_deps := \
            $(call wondermake.topologically_sorted_unique_deep_deps,$(wondermake.template.scope),$(if
              $(call wondermake.equals,static_executable,$(call wondermake.inherit_unique,$(wondermake.template.scope),type)),,x)))
          $(wondermake.template.binary_file): | $(wondermake.template.deep_deps)
          $(wondermake.template.scope).libs += $(foreach d,$(wondermake.template.deep_deps)
            ,$(if $(filter-out headers objects,$(call wondermake.inherit_unique,$d,type))
              ,$(or $($d.name),$d)))
          $(eval undefine wondermake.template.deep_deps)
        )
      )
    )
  )
endef

###############################################################################
# Define the commands ultimately used by the template recipes

# Command to preprocess a c++ source file
define wondermake.cbase.cpp_command # $1 = scope
	$(or $(call wondermake.user_override,CPP),$(call wondermake.inherit_unique,$1,cpp)) \
	$(call wondermake.inherit_unique,$1,cpp_flags_out_mode) \
	$(call wondermake.inherit_unique,$1,cpp_flags[$(call wondermake.inherit_unique,$1,lang)]) \
	$(call wondermake.inherit_unique,$1,cxx_flags[$(call wondermake.inherit_unique,$1,type)]) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,cpp_define_pattern),$(call wondermake.inherit_append,$1,define)) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,cpp_undefine_pattern),$(call wondermake.inherit_append,$1,undefine)) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,cpp_include_pattern),$(call wondermake.inherit_prepend,$1,include)) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,cpp_include_path_pattern),$(call wondermake.inherit_prepend,$1,include_path)) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,cpp_framework_pattern),$(call wondermake.inherit_prepend,$1,frameworks)) \
	$(shell $(call wondermake.inherit_unique,$1,pkg_config_prog) --cflags '$(call wondermake.inherit_append,$1,pkg_config)') \
	$(call wondermake.inherit_append,$1,cpp_flags) \
	$(CPPFLAGS) \
	$$(abspath $$<)
endef

# Command to precompile a c++ source file to a binary module interface file
define wondermake.cbase.mxx_command # $1 = scope, $(module_map) is a var private to the bmi file rule (see .d files)
	$(or $(call wondermake.user_override,CXX),$(call wondermake.inherit_unique,$1,cxx)) \
	$(call wondermake.inherit_unique,$1,mxx_flags_out_mode) \
	$(call wondermake.inherit_unique,$1,mxx_flags[$(call wondermake.inherit_unique,$1,lang)]) \
	$(call wondermake.inherit_unique,$1,cxx_flags[$(call wondermake.inherit_unique,$1,type)]) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,cxx_module_path_pattern),$(call wondermake.inherit_prepend,$1,module_path)) \
	$$(patsubst %,$(call wondermake.inherit_unique,$1,cxx_module_map_pattern),$(call wondermake.inherit_prepend,$1,module_map) $$(module_map)) \
	$(shell $(call wondermake.inherit_unique,$1,pkg_config_prog) --cflags-only-other '$(call wondermake.inherit_append,$1,pkg_config)') \
	$(call wondermake.inherit_append,$1,cxx_flags) \
	$(CXXFLAGS) \
	$$<
endef

# Command to compile a c++ source file to an object file
define wondermake.cbase.cxx_command # $1 = scope, $(module_map) is a var private to the object file rule (see .d files)
	$(or $(call wondermake.user_override,CXX),$(call wondermake.inherit_unique,$1,cxx)) \
	$(call wondermake.inherit_unique,$1,cxx_flags_out_mode) \
	$(call wondermake.inherit_unique,$1,cxx_flags[$(call wondermake.inherit_unique,$1,lang)]) \
	$(call wondermake.inherit_unique,$1,cxx_flags[$(call wondermake.inherit_unique,$1,type)]) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,cxx_module_path_pattern),$(call wondermake.inherit_prepend,$1,module_path)) \
	$$(patsubst %,$(call wondermake.inherit_unique,$1,cxx_module_map_pattern),$(call wondermake.inherit_prepend,$1,module_map) $$(module_map)) \
	$(shell $(call wondermake.inherit_unique,$1,pkg_config_prog) --cflags-only-other '$(call wondermake.inherit_append,$1,pkg_config)') \
	$(call wondermake.inherit_append,$1,cxx_flags) \
	$(CXXFLAGS) \
	$$<
endef

# Command to link object files and produce an executable or shared library file
define wondermake.cbase.ld_command # $1 = scope
	$(or $(call wondermake.user_override,LD),$(call wondermake.inherit_unique,$1,ld)) \
	$(call wondermake.inherit_unique,$1,ld_flags_out_mode) \
	$(call wondermake.inherit_unique,$1,ld_flags[$(call wondermake.inherit_unique,$1,type)]) \
	$(call wondermake.inherit_append,$1,ld_flags) \
	$(LDFLAGS) \
	$$(filter-out $$(wondermake.bld_dir)scopes/$1/ld_command $$(wondermake.bld_dir)scopes/$1/obj_files,$$+) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,ld_lib_path_pattern),$(call wondermake.inherit_append,$1,libs_path)) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,ld_lib_pattern),$(call wondermake.inherit_append,$1,libs)) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,ld_framework_pattern),$(call wondermake.inherit_append,$1,frameworks)) \
	$(shell $(call wondermake.inherit_unique,$1,pkg_config_prog) --libs '$(call wondermake.inherit_append,$1,pkg_config)') \
	$(LDLIBS)
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
# Execute the template

compile_commands.json := # this is an immediate var

# Execute the template for each user-declared scope that's using the cbase toolchain
$(foreach wondermake.template.scope,$(wondermake),\
	$(if $(call wondermake.equals,cbase,$(call wondermake.inherit_unique,$(wondermake.template.scope),toolchain)), \
		$(eval $(value wondermake.template))))

ifneq '' '$(filter template,$(wondermake.verbose))'
  $(info )
  $(info ######################### End of template execution ###########################)
  $(info ###############################################################################)
  $(info ###############################################################################)
  $(info ###############################################################################)
  $(info )
endif

###############################################################################
# Undefine the template

undefine wondermake.template
undefine wondermake.template.define_vars
undefine wondermake.template.undefine_vars
undefine wondermake.template.rules_with_evaluated_recipes

###############################################################################
# Compilation database (compile_commands.json)

compile_commands.json: $(wondermake.compile_commands.json)
	$(call wondermake.announce,$@)
	printf '[\n' > $@; \
	cat >> $@; \
	printf ']\n' >> $@
#TODO wondermake.default: compile_commands.json

###############################################################################
endif # ifndef wondermake.cbase.template.included
