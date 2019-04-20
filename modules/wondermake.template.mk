# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

###############################################################################
# Template

define wondermake.template
  ifneq '' '$(filter template,$(wondermake.verbose))'
    $(info )
    $(info ############### Template execution for scope $(wondermake.template.scope) ###############)
    $(info )
  endif

  $(eval $(value wondermake.template.vars.define))
  ifneq '' '$(filter template,$(wondermake.verbose))'
    $(info $(wondermake.template.vars.define))
  endif

  $(eval $(wondermake.template.rules))
  ifneq '' '$(filter template,$(wondermake.verbose))'
    $(info $(wondermake.template.rules))
  endif

  $(eval $(wondermake.template.vars.undefine))
endef

###############################################################################

define wondermake.template.vars.define
  wondermake.template.src_dir := $(call wondermake.inherit_unique,$(wondermake.template.scope),src_dir)

  wondermake.template.mxx_files := $(patsubst $(wondermake.template.src_dir)%,%, \
	$(shell find $(addprefix $(wondermake.template.src_dir),$($(wondermake.template.scope).src)) \
		-name '' \
		$(patsubst %,-o -name '*.%', \
			$(or \
				$(call wondermake.inherit_unique,$(wondermake.template.scope),mxx_suffix) \
				$(call wondermake.inherit_unique,$(wondermake.template.scope),mxx_suffix[$(call wondermake.inherit_unique,$(wondermake.template.scope),lang)])))))
  wondermake.template.cxx_files := $(patsubst $(wondermake.template.src_dir)%,%, \
	$(shell find $(addprefix $(wondermake.template.src_dir),$($(wondermake.template.scope).src)) \
	 	-name '' \
		 $(patsubst %,-o -name '*.%', \
			$(or \
				$(call wondermake.inherit_unique,$(wondermake.template.scope),cxx_suffix) \
				$(call wondermake.inherit_unique,$(wondermake.template.scope),cxx_suffix[$(call wondermake.inherit_unique,$(wondermake.template.scope),lang)])))))

  wondermake.template.mxx_d_files := $(addsuffix .d,$(wondermake.template.mxx_files))
  wondermake.template.cxx_d_files := $(addsuffix .d,$(wondermake.template.cxx_files))

  wondermake.template.bmi_suffix := $(call wondermake.inherit_unique,$(wondermake.template.scope),bmi_suffix)
  wondermake.template.obj_suffix := $(call wondermake.inherit_unique,$(wondermake.template.scope),obj_suffix)

  wondermake.template.obj_files := $(addsuffix .$(wondermake.template.obj_suffix),$(wondermake.template.mxx_files) $(wondermake.template.cxx_files))

  wondermake.template.name := $(or $($(wondermake.template.scope).name),$(wondermake.template.scope))
  wondermake.template.binary_file := $(wondermake.template.name:%=$(call wondermake.inherit_unique,$(wondermake.template.scope),binary_file_pattern[$(call wondermake.inherit_unique,$(wondermake.template.scope),type)]))

  wondermake.template.cpp_command := $(call wondermake.template.recipe.cpp_command,$(wondermake.template.scope))
  wondermake.template.cxx_command := $(call wondermake.template.recipe.cxx_command,$(wondermake.template.scope))
  wondermake.template.mxx_command := $(call wondermake.template.recipe.mxx_command,$(wondermake.template.scope))
  wondermake.template.ld_command  := $(call wondermake.template.recipe.ld_command,$(wondermake.template.scope))
endef

###############################################################################

define wondermake.template.vars.undefine
  undefine wondermake.template.src_dir
  undefine wondermake.template.cxx_files
  undefine wondermake.template.mxx_files
  undefine wondermake.template.src_files
  undefine wondermake.template.bmi_suffix
  undefine wondermake.template.obj_suffix
  undefine wondermake.template.obj_files
  undefine wondermake.template.name
  undefine wondermake.template.binary_file
  undefine wondermake.template.cpp_command
  undefine wondermake.template.cxx_command
  undefine wondermake.template.mxx_command
  undefine wondermake.template.ld_command
endef

###############################################################################

define wondermake.template.rules

  # Phony or not phony targets for this scope
  wondermake.default: $(wondermake.template.scope)
  # If scope has explicitely defined a name that is different from the scope name
  ifneq '$(wondermake.template.scope)' '$(wondermake.template.name)'
    .PHONY: $(wondermake.template.scope)
    $(wondermake.template.scope): $(wondermake.template.name)
  endif
  # If there is a link or archive step
  ifneq '' '$(wondermake.template.binary_file)'
    # If the platform has any prefix or suffix added to the binary file name
    ifneq '$(wondermake.template.name)' '$(wondermake.template.binary_file)'
      .PHONY: $(wondermake.template.name)
      $(wondermake.template.name): $(wondermake.template.binary_file)
    endif
  else # No link nor archive step: target is just the list of object files
    $(wondermake.template.name): $(wondermake.template.obj_files)
  endif

  # Rule to create an output directory
  $(foreach s,$(sort $(dir $(wondermake.template.mxx_files) $(wondermake.template.cxx_files))), \
    ${wondermake.newline}  $s: ; mkdir -p $$@ \
  )

  # Rule to preprocess a c++ source file (the output directory creation is triggered here)
  $(foreach s,$(wondermake.template.mxx_files) $(wondermake.template.cxx_files), \
    ${wondermake.newline}  $s.ii: $(wondermake.template.src_dir)$s wondermake.configure | $(dir $s) \
    ${wondermake.newline}	$$(call wondermake.info,preprocess $$< to $$@) \
    ${wondermake.newline}	$$(call wondermake.template.recipe.cpp_command,$(wondermake.template.scope)) \
    ${wondermake.newline}  wondermake.clean += $s.ii
    ${wondermake.newline} \
  )

  # Rule to parse ISO C++ module keywords in an interface file
  $(wondermake.template.mxx_d_files): %.d: %.ii
	$$(call wondermake.info,parse export module and import keywords $$< to $$@)
	$$(call wondermake.template.recipe.parse_export_module_keyword,$$(basename $$*).$(wondermake.template.bmi_suffix))
	$$(call wondermake.template.recipe.parse_import_keyword,$$*.$(wondermake.template.obj_suffix) $$(basename $$*).$(wondermake.template.bmi_suffix))
  wondermake.dynamically_generated_makefiles += $(wondermake.template.mxx_d_files)
  wondermake.clean += $(wondermake.template.mxx_d_files)

  # Rule to parse ISO C++ module keywords in an implementation file
  $(wondermake.template.cxx_d_files): %.d: %.ii
	$$(call wondermake.info,parse module and import keywords $$< to $$@)
	$$(call wondermake.template.recipe.parse_module_keyword,$$*.$(wondermake.template.obj_suffix))
	$$(call wondermake.template.recipe.parse_import_keyword,$$*.$(wondermake.template.obj_suffix))
  wondermake.dynamically_generated_makefiles += $(wondermake.template.cxx_d_files)
  wondermake.clean += $(wondermake.template.cxx_d_files)

  # Rule to precompile a c++ source file to a binary module interface file
  $(foreach s,$(wondermake.template.mxx_files), \
    ${wondermake.newline}  $(basename $s).$(wondermake.template.bmi_suffix): $s.ii \
    ${wondermake.newline}	$$(call wondermake.info,precompile module interface $$< to $$@) \
    ${wondermake.newline}	$$(call wondermake.template.recipe.mxx_command,$(wondermake.template.scope)) \
    ${wondermake.newline}  wondermake.clean += $(basename $s).$(wondermake.template.bmi_suffix) \
    ${wondermake.newline} \
  )

  # Rule to compile a c++ source file to an object file
  $(wondermake.template.obj_files): %.$(wondermake.template.obj_suffix): %.ii
	$$(call wondermake.info,compile $$< to $$@)
	$$(call wondermake.template.recipe.cxx_command,$(wondermake.template.scope))
  wondermake.clean += $(wondermake.template.obj_files)

  ifneq '' '$(wondermake.template.binary_file)'
    # Rule to trigger relinking when a source file (and hence its derived object file) is removed
    $(call wondermake.template.rules.sign,$(wondermake.template.scope).src_filesz,$(wondermake.template.mxx_files) $(wondermake.template.cxx_files),sort)
    $(wondermake.template.scope).src_files: wondermake.force
		$$(call wondermake.template.recipe.sign,$(wondermake.template.scope).src_files,$(wondermake.template.mxx_files) $(wondermake.template.cxx_files),sort)
    wondermake.clean += $(wondermake.template.scope).src_files
    # Command to link object files and produce an executable or shared library file
    $(wondermake.template.binary_file): $(wondermake.template.obj_files) $(wondermake.template.scope).src_files
		$$(call wondermake.info,link $$@ from objects $(wondermake.template.obj_files))
		$$(call wondermake.template.recipe.ld_command,$(wondermake.template.scope))
    wondermake.clean += $(wondermake.template.binary_file)
  endif
endef

# Rule to update a file with a content when it has changed
define wondermake.template.rules.sign # $1 = target, $2 = content, $3 = sort
  $1: wondermake.force
	$$(call wondermake.template.recipe.sign,$1,$2,$3)
  wondermake.clean += $1
endef

# Command to update a file with a content when it has changed
define wondermake.template.recipe.sign # $1 = target, $2 = content, $3 = sort
	$(call wondermake.info,sign $1)
	$(eval $1.old := $(file < $1))
	$(eval $1.new := $(if $3,$($3 $2),$2))
	$(if $(call wondermake.equals,$($1.new),$($1.old)), \
		$(call wondermake.trace,no change), \
		$(call wondermake.trace,changed: \
			$(patsubst %,+%,$(filter-out $($1.old),$($1.new))) \
			$(patsubst %,-%,$(filter-out $($1.new),$($1.old))) \
		) \
		$(file > $1,$($1.new)) \
	)
	$(eval undefine $1.old)
	$(eval undefine $1.new)
endef

###############################################################################
# Recipe commands

# Command to preprocess a c++ source file
define wondermake.template.recipe.cpp_command # $1 = scope
	$(or $(call wondermake.user_override,CPP),$(call wondermake.inherit_unique,$1,cpp)) \
	$(call wondermake.inherit_unique,$1,cpp_flags_out_mode) \
	$(call wondermake.inherit_unique,$1,cpp_flags[$(call wondermake.inherit_unique,$1,lang)]) \
	$(call wondermake.inherit_unique,$1,cxx_flags[$(call wondermake.inherit_unique,$1,type)]) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,cpp_define_pattern),$(call wondermake.inherit_append,$1,define)) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,cpp_undefine_pattern),$(call wondermake.inherit_append,$1,undefine)) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,cpp_include_pattern),$(call wondermake.inherit_prepend,$1,include)) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,cpp_include_path_pattern),$(call wondermake.inherit_prepend,$1,include_path)) \
	$(call wondermake.inherit_append,$1,cpp_flags) \
	$(CPPFLAGS) \
	$<
endef

# Command to precompile a c++ source file to a binary module interface file
define wondermake.template.recipe.mxx_command # $1 = scope, $(module_map) is a var private to the bmi file rule (see .d files)
	$(or $(call wondermake.user_override,CXX),$(call wondermake.inherit_unique,$1,cxx)) \
	$(call wondermake.inherit_unique,$1,mxx_flags_out_mode) \
	$(call wondermake.inherit_unique,$1,mxx_flags[$(call wondermake.inherit_unique,$1,lang)]) \
	$(call wondermake.inherit_unique,$1,cxx_flags[$(call wondermake.inherit_unique,$1,type)]) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,cxx_module_path_pattern),$(call wondermake.inherit_prepend,$1,module_path)) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,cxx_module_map_pattern),$(call wondermake.inherit_prepend,$1,module_map) $(module_map)) \
	$(call wondermake.inherit_append,$1,cxx_flags) \
	$(CXXFLAGS) \
	$<
endef

# Command to compile a c++ source file to an object file
define wondermake.template.recipe.cxx_command # $1 = scope, $(module_map) is a var private to the object file rule (see .d files)
	$(or $(call wondermake.user_override,CXX),$(call wondermake.inherit_unique,$1,cxx)) \
	$(call wondermake.inherit_unique,$1,cxx_flags_out_mode) \
	$(call wondermake.inherit_unique,$1,cxx_flags[$(call wondermake.inherit_unique,$1,lang)]) \
	$(call wondermake.inherit_unique,$1,cxx_flags[$(call wondermake.inherit_unique,$1,type)]) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,cxx_module_path_pattern),$(call wondermake.inherit_prepend,$1,module_path)) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,cxx_module_map_pattern),$(call wondermake.inherit_prepend,$1,module_map) $(module_map)) \
	$(call wondermake.inherit_append,$1,cxx_flags) \
	$(CXXFLAGS) \
	$<
endef

# Command to link object files and produce an executable or shared library file
define wondermake.template.recipe.ld_command # $1 = scope
	$(or $(call wondermake.user_override,LD),$(call wondermake.inherit_unique,$1,ld)) \
	$(call wondermake.inherit_unique,$1,ld_flags_out_mode) \
	$(call wondermake.inherit_unique,$1,ld_flags[$(call wondermake.inherit_unique,$1,type)]) \
	$(call wondermake.inherit_append,$1,ld_flags) \
	$(LDFLAGS) \
	$(filter-out $1.src_files,$+) \
	$(patsubst %,$(call wondermake.inherit_unique,$1,ld_libs_pattern),$(call wondermake.inherit_append,$1,libs)) \
	$(LDLIBS)
endef

# Command to parse ISO C++ module "export module" keywords in an interface file
define wondermake.template.recipe.parse_export_module_keyword # $1 = bmi file
	sed -rn 's,^[ 	]*export[ 	]+module[ 	]+([^[ 	;]+)[ 	;],wondermake.module_map[\1] := $1,p' $< >> $@
endef

# Command to parse ISO C++ module "module" keywords in an implementation file
define wondermake.template.recipe.parse_module_keyword # $1 = obj file
	sed -rn 's,^[ 	]*module[ 	]+([^[ 	;]+)[ 	;],$1: $$$$(wondermake.module_map[\1])\n$1: private module_map = $$(wondermake.module_map[\1]),p' $< >> $@
endef

# Command to parse ISO C++ module "import" keywords in an interface or implementation file
define wondermake.template.recipe.parse_import_keyword # $1 = targets (obj file, or obj+bmi files)
	sed -rn 's,^[         ]*(export[      ]+|)import[     ]+([^[  ;]+)[   ;],$1: $$$$(wondermake.module_map[\2])\n$1: private module_map += $$(wondermake.module_map[\2]:%=\2=%),p' $< >> $@
endef

###############################################################################
# Execute the template

# Add a default inheritance on the wondermake scope for each user-declared scope
$(foreach wondermake.template.scope, $(wondermake), \
	$(if $(filter wondermake,$(call wondermake.inherit_root,$(wondermake.template.scope))) \
		,,$(eval $(call wondermake.inherit_root,$(wondermake.template.scope)).inherit := wondermake)))
		# Note: the same root may be visited multiple times so we must take care of not making the wondermake scope inherit from itself.

wondermake.dynamically_generated_makefiles := # this is an immediate var

# Execute the template for each user-declared scope
$(foreach  wondermake.template.scope, $(wondermake), $(eval $(value wondermake.template)))

ifneq '' '$(filter template,$(wondermake.verbose))'
  $(info )
  $(info ############### End of template execution ###############)
  $(info )
endif
