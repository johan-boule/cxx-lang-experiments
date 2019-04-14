# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

###############################################################################
# Source files suffixes

wondermake.cpp_suffix[c]   := i
wondermake.cxx_suffix[c]   := c
wondermake.hxx_suffix[c]   := h
wondermake.cpp_suffix[c++] := ii
wondermake.cxx_suffix[c++] := c++ cxx cpp cc C
wondermake.hxx_suffix[c++] := h++ hxx hpp hh H $(wondermake.hxx_suffix[c])
wondermake.mxx_suffix[c++] := m++ mxx mpp ixx cppm
wondermake.cpp_suffix[objective-c]   := $(wondermake.cpp_suffix[c])
wondermake.cxx_suffix[objective-c]   := $(wondermake.cxx_suffix[c]) m
wondermake.hxx_suffix[objective-c]   := $(wondermake.hxx_suffix[c])
wondermake.cpp_suffix[objective-c++] := $(wondermake.cpp_suffix[c++])
wondermake.cxx_suffix[objective-c++] := $(wondermake.cxx_suffix[c++]) mm
wondermake.hxx_suffix[objective-c++] := $(wondermake.hxx_suffix[c++])
#wondermake.mxx_suffix[objective-c++] := $(wondermake.mxx_suffix[c++])

###############################################################################
# Overridable programs

wondermake.cpp    ?= $(or $(call wondermake.user_override,CPP),$(wondermake.cxx)) #-E
wondermake.cxx    ?= $(or $(call wondermake.user_override,CXX),clang++)
wondermake.ld     ?= $(or $(call wondermake.user_override,LD),$(wondermake.cxx))
wondermake.ar     ?= $(or $(call wondermake.user_override,AR),ar)
wondermake.ranlib ?= $(or $(call wondermake.user_override,RANLIB),$(wondermake.ar) s)

###############################################################################
# Toolchain configuration variables

wondermake.cpp_flags_out_mode = -o$@ -E -MMD -MF$(basename $@).d -MT$@ -MP # beware: $* not available if no stem
wondermake.cxx_flags_out_mode = -o$@ -c
wondermake.mxx_flags_out_mode = -o$@ --precompile
wondermake.ld_flags_out_mode  = -o$@

wondermake.cpp_flags[c++]           := -xc++
wondermake.cxx_flags[c++]           := -xc++-cpp-output -fmodules-ts
wondermake.mxx_flags[c++]           := -xc++-module -fmodules-ts
wondermake.cpp_flags[objective-c++] := -xobjective-c++
wondermake.cxx_flags[objective-c++] := -xobjective-c++-cpp-output
wondermake.cpp_flags[c]             := -xc
wondermake.cxx_flags[c]             := -xc-cpp-output
wondermake.cpp_flags[objective-c]   := -xobjective-c
wondermake.cxx_flags[objective-c]   := -xobjective-c-cpp-output

wondermake.cpp_define_pattern := -D%
wondermake.cpp_undefine_pattern := -U%
wondermake.cpp_include_pattern := -include=%
wondermake.cpp_include_path_pattern := -I%
wondermake.cxx_module_map_pattern := -fmodule-file=%
wondermake.cxx_module_path_pattern := -fprebuilt-module-path=%
wondermake.ld_lib_pattern := -l%

wondermake.cxx_flags[shared_lib] := -fPIC
wondermake.ld_flags[shared_lib]  := -shared

wondermake.bmi_suffix := pcm
wondermake.obj_suffix := o

wondermake.binary_file_pattern[executable] := %
wondermake.binary_file_pattern[shared_lib] := lib%.so
wondermake.binary_file_pattern[dlopen_lib] := %.so
wondermake.binary_file_pattern[static_lib] := lib%.a

###############################################################################
# Template

define wondermake.template
  ifneq '' '$(wondermake.verbose)'
    $(info )
    $(info ############### Template execution for scope $(wondermake.template.scope) ###############)
    $(info )
  endif

  $(eval $(value wondermake.template.vars.define))
  ifneq '' '$(wondermake.verbose)'
    $(info $(wondermake.template.vars.define))
  endif

  $(eval $(wondermake.template.rules))
  ifneq '' '$(wondermake.verbose)'
    $(info $(wondermake.template.rules))
  endif

  $(eval $(value wondermake.template.vars.undefine))
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

  wondermake.template.src_files := $(wondermake.template.mxx_files) $(wondermake.template.cxx_files)

  wondermake.template.mxx_d_files := $(addsuffix .d,$(wondermake.template.mxx_files))
  wondermake.template.cxx_d_files := $(addsuffix .d,$(wondermake.template.cxx_files))

  wondermake.template.bmi_suffix := $(call wondermake.inherit_unique,$(wondermake.template.scope),bmi_suffix)
  wondermake.template.obj_suffix := $(call wondermake.inherit_unique,$(wondermake.template.scope),obj_suffix)

  wondermake.template.obj_files := $(addsuffix .$(wondermake.template.obj_suffix),$(wondermake.template.mxx_files) $(wondermake.template.cxx_files))

  wondermake.template.name := $(or $($(wondermake.template.scope).name),$(wondermake.template.scope))
  wondermake.template.binary_file := $(wondermake.template.name:%=$(call wondermake.inherit_unique,$(wondermake.template.scope),binary_file_pattern[$(call wondermake.inherit_unique,$(wondermake.template.scope),type)]))
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
endef

###############################################################################

define wondermake.template.rules
  wondermake.all: $(wondermake.template.scope)
  ifneq '$(wondermake.template.scope)' '$(wondermake.template.name)'
    .PHONY: $(wondermake.template.scope)
    $(wondermake.template.scope): $(wondermake.template.name)
  endif
  ifneq '$(wondermake.template.name)' '$(wondermake.template.binary_file)'
    .PHONY: $(wondermake.template.name)
    $(wondermake.template.name): $(wondermake.template.binary_file)
  endif

  $(foreach s,$(wondermake.template.mxx_files) $(wondermake.template.cxx_files), \
    ${wondermake.newline}  $s.ii: $(wondermake.template.src_dir)$s ; \
		$$(call wondermake.template.recipee.cpp_command,$(wondermake.template.scope)) \
    ${wondermake.newline}  wondermake.clean += $s.ii \
    ${wondermake.newline} \
  )

  $(wondermake.template.mxx_d_files): %.d: %.ii
	$$(call wondermake.template.recipee.parse_export_module_keyword,$(wondermake.template.bmi_suffix))
	$$(call wondermake.template.recipee.parse_import_keyword,$$*.$(wondermake.template.obj_suffix) $$(basename $$*).$(wondermake.template.bmi_suffix))
  wondermake.dynamically_generated_makefiles += $(wondermake.template.mxx_d_files)
  wondermake.clean += $(wondermake.template.mxx_d_files)

  $(wondermake.template.cxx_d_files): %.d: %.ii
	$$(call wondermake.template.recipee.parse_module_keyword,$(wondermake.template.obj_suffix))
	$$(call wondermake.template.recipee.parse_import_keyword,$$*.$(wondermake.template.obj_suffix))
  wondermake.dynamically_generated_makefiles += $(wondermake.template.cxx_d_files)
  wondermake.clean += $(wondermake.template.cxx_d_files)

  $(foreach s,$(wondermake.template.mxx_files), \
    ${wondermake.newline}  $(basename $s).$(wondermake.template.bmi_suffix): $s.ii ; \
		$$(call wondermake.template.recipee.mxx_command,$(wondermake.template.scope)) \
    ${wondermake.newline}  wondermake.clean += $(basename $s).$(wondermake.template.bmi_suffix) \
    ${wondermake.newline} \
  )

  $(wondermake.template.obj_files): %.$(wondermake.template.obj_suffix): %.ii; \
	$$(call wondermake.template.recipee.cxx_command,$(wondermake.template.scope))
  wondermake.clean += $(wondermake.template.obj_files)

  $(wondermake.template.binary_file): $(wondermake.template.obj_files); \
	$$(call wondermake.template.recipee.ld_command,$(wondermake.template.scope))
  wondermake.clean += $(wondermake.template.binary_file)
endef

###############################################################################
# Recipee commands

# Command to preprocess a c++ source file
define wondermake.template.recipee.cpp_command # $1 = scope
	@$(call wondermake.echo,preprocess $< to $@)
	@mkdir -p $(@D)
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
define wondermake.template.recipee.mxx_command # $1 = scope, $(module_map) is a var private to the object file rule (see .d files)
	@$(call wondermake.echo,precompile module interface $< to $@)
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
define wondermake.template.recipee.cxx_command # $1 = scope, $(module_map) is a var private to the object file rule (see .d files)
	@$(call wondermake.echo,compile $< to $@)
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
define wondermake.template.recipee.ld_command # $1 = scope
	@$(call wondermake.echo,link $@ from objects $+)
	$(or $(call wondermake.user_override,LD),$(call wondermake.inherit_unique,$1,ld)) \
	$(call wondermake.inherit_unique,$1,ld_flags_out_mode) \
	$(call wondermake.inherit_unique,$1,ld_flags[$(call wondermake.inherit_unique,$1,type)]) \
	$(call wondermake.inherit_append,$1,ld_flags) \
	$(LDFLAGS) \
	$+ \
	$(patsubst %,$(call wondermake.inherit_unique,$1,ld_libs_pattern),$(call wondermake.inherit_append,$1,libs)) \
	$(LDLIBS)
endef

# ISO C++ module parsers http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2019/p1103r3.pdf
# TODO The following is not supported:
# - partitions:
#     export module foo:part;
#     module foo:part;
#     module foo;
#     import :part; // imports foo:part
# - global module fragment:
#     module;
#     #include "header"
#     export module foo;
# - header units:
#     import "header"
#     import <header>

define wondermake.template.recipee.parse_export_module_keyword # $1 = bmi_suffix
	@$(call wondermake.echo,parse export module keyword $< >> $@)
	sed -rn 's,^[ 	]*export[ 	]+module[ 	]+([^[ 	;]+)[ 	;],wondermake.module_map[\1] := $(basename $*).$1,p' $< >> $@
endef

define wondermake.template.recipee.parse_module_keyword # $1 = obj_suffix
	@$(call wondermake.echo,parse module keyword $< >> $@)
	sed -rn 's,^[ 	]*module[ 	]+([^[ 	;]+)[ 	;],$*.$1: $$$$(wondermake.module_map[\1])\n$*.$1: private module_map = $$(wondermake.module_map[\1]),p' $< >> $@
endef

define wondermake.template.recipee.parse_import_keyword # $1 = targets
	@$(call wondermake.echo,parse import keyword $< >> $@)
	sed -rn 's,^[         ]*(export[      ]+|)import[     ]+([^[  ;]+)[   ;],$1: $$$$(wondermake.module_map[\2])\n$1: private module_map += $$(wondermake.module_map[\2]:%=\2=%),p' $< >> $@
endef

###############################################################################
# Clean rule

wondermake.clean := # this is an immediate var

wondermake.clean:
	@$(call wondermake.echo,clean)
	rm -Rf $(wondermake.clean)
	rmdir -p $(dir $(wondermake.clean)) 2>/dev/null || true

###############################################################################
# Utility functions

# This function finds a word in a list
# $1 = the word to find
# $2 = the list in which to search the word for
# returns the word if found, or else the empty string
wondermake.find_word = $(if $(findstring <$1>,$(patsubst %,<%>,$2)),$1)

# This function checks whether the user has overriden a variable.
# $1 = the variable for which you want to test the origin
# returns the value of the variable if the user calling make has overridden it, or else the empty string
wondermake.user_override = $(if $(call wondermake.find_word,$(origin $1),undefined default),,$($1))

# The newline character (useful in foreach statements)
define wondermake.newline


endef

###############################################################################
# Logging functions

# The escape character (used for coloring the messages in the terminal)
wondermake.escape_char := $(shell echo -en '\e')

# check whether the verbose var is set or make is not silent mode
ifeq '' '$(if $(wondermake.verbose),,$(findstring s, $(firstword x$(MAKEFLAGS))))'
  # if so, emit messages (both make phases have their own color)
  wondermake.echo = echo $${MAKE_TERMOUT:+'\033[$(if $(MAKE_RESTARTS),1;36,1;34)m'}'$1'$${MAKE_TERMOUT:+'\033[0m'}
else
  # else, be quiet
  wondermake.echo := :
endif

###############################################################################
# Scope inheritance support functions

# Find the root scope of the inheritance hierarchy ($1 = scope)
wondermake.inherit_root = $(if $($1.inherit),$(call $0,$($1.inherit)),$1)

# Find the value of a variable by traversing the hierarchy ($1 = scope, $2 = var)
wondermake.inherit_unique = $(or $($1.$2),$(if $($1.inherit),$(call $0,$($1.inherit),$2)))

# Concatenate, by appending, the value of a list variable by traversing the hierarchy ($1 = scope, $2 = var)
wondermake.inherit_append = $($1.$2) $(if $($1.inherit),$(call $0,$($1.inherit),$2))

# Concatenate, by prepending, the value of a list variable by traversing the hierarchy ($1 = scope, $2 = var)
wondermake.inherit_prepend = $(if $($1.inherit),$(call $0,$($1.inherit),$2)) $($1.$2)

###############################################################################
# Execute the template

# Add a default inheritance on the wondermake scope for each user-declared scope
$(foreach wondermake.template.scope, $(wondermake), \
	$(if $(call wondermake.find_word,wondermake,$(call wondermake.inherit_root,$(wondermake.template.scope))) \
		,,$(eval $(call wondermake.inherit_root,$(wondermake.template.scope)).inherit := wondermake)))
		# Note: the same root may be visited multiple times so we must take care of not making the wondermake scope inherit from itself.

wondermake.dynamically_generated_makefiles := # this is an immediate var

# Execute the template for each user-declared scope
$(foreach  wondermake.template.scope, $(wondermake), $(eval $(value wondermake.template)))

ifneq '' '$(wondermake.verbose)'
  $(info )
  $(info ############### End of template execution ###############)
  $(info )
endif

###############################################################################
 # Include the dynamically generated makefiles
 # GNU make will first build (if need be) all of these makefiles
 # before restarting itself to build the actual goal.
 #
 # In the case of implicit dependency files (.d files),
 # this will in turn trigger the building of the .ii files, on which the .d files depend.
 # So, preprocessing occurs on the first make phase.
 # Secondary expansion is used to allow variables to be defined out of order.
 # (Without secondary expansion, we have to include $(srcm).d before $(src).d)
ifneq '$(MAKECMDGOALS)' 'clean' # don't remake the .d files when cleaning
  .SECONDEXPANSION:
  -include $(wondermake.dynamically_generated_makefiles)
endif
###############################################################################
