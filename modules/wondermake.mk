# Copyright 2018-2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

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
wondermake.mxx_suffix[objective-c++] := $(wondermake.mxx_suffix[c++])

# This function finds an element in a list
wondermake.find_element = $(if $(findstring <$1>,$(patsubst %,<%>,$2)),$1)

# This function returns a nonempty string when the user calling make has not overridden the variable passed as argument.
wondermake.is_not_overriden_by_user = $(call wondermake.find_element,$(origin $1),undefined default)

ifneq '' '$(call wondermake.is_not_overriden_by_user,CXX)'
  undefine CXX
  wondermake.cxx := $(shell command -v clang++;) # command is a shell built-in, so we need that ';' to force make to really invoke the shell
endif
ifneq '' '$(call wondermake.is_not_overriden_by_user,CPP)'
  # The user calling make has not overridden CPP
  undefine CPP
  wondermake.cpp := $(or $(CXX),$(wondermake.cxx)) #-E
endif
ifneq '' '$(call wondermake.is_not_overriden_by_user,LD)'
  # The user calling make has not overridden LD
  undefine LD
  wondermake.ld := $(or $(CXX),$(wondermake.cxx))
endif

wondermake.cpp_flags = -o$@ -E -MMD -MF$*.d -MT$@ -MP
wondermake.cxx_flags = -o$@ -c
wondermake.mxx_flags = -o$@ -precompile
wondermake.ld_flags  = -o$@

wondermake.cpp_flags[c++] := -xc++
wondermake.cxx_flags[c++] := -xc++-cpp-output -fmodules-ts
wondermake.mxx_flags[c++] := -xc++-module -fmodules-ts
wondermake.cpp_flags[objective-c++] := -xobjective-c++
wondermake.cxx_flags[objective-c++] := -xobjective-c++-cpp-output
wondermake.cpp_flags[c] := -xc
wondermake.cxx_flags[c] := -xc-cpp-output
wondermake.cpp_flags[objective-c] := -xobjective-c
wondermake.cxx_flags[objective-c] := -xobjective-c-cpp-output

wondermake.cpp_define_pattern := -D%
wondermake.cpp_undefine_pattern := -U%
wondermake.cpp_include_pattern := -include=%
wondermake.cpp_include_path_pattern := -I%
wondermake.ld_lib_pattern := -l%

wondermake.cxx_flags[shared_lib] := -fPIC
wondermake.ld_flags[shared_lib]  := -shared

wondermake.bmi_suffix := pcm
wondermake.obj_suffix := o

wondermake.binary_file_pattern[exe]        := %
wondermake.binary_file_pattern[shared_lib] := lib%.so
wondermake.binary_file_pattern[dlopen_lib] := %.so
wondermake.binary_file_pattern[static_lib] := lib%.a

# Command to preprocess a c++ file
define wondermake.template.recipee.cpp_command # $1 = scope
	$(or $(CPP),$(call wondermake.inherit_unique,$1,cpp)) \
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

# Command to produce a binary module interface file
define wondermake.template.recipee.mxx_command # $1 = scope
	$(or $(CXX),$(call wondermake.inherit_unique,$1,cxx)) \
	$(call wondermake.inherit_unique,$1,mxx_flags[$(call wondermake.inherit_unique,$1,lang)]) \
	$(call wondermake.inherit_unique,$1,cxx_flags[$(call wondermake.inherit_unique,$1,type)]) \
	$(call wondermake.inherit_append,$1,cxx_flags) \
	$(CXXFLAGS) \
	$<
endef

# Command to compile a module implementation or interface file to an object file
define wondermake.template.recipee.cxx_command # $1 = scope
	$(or $(CXX),$(call wondermake.inherit_unique,$1,cxx)) \
	$(call wondermake.inherit_unique,$1,cxx_flags[$(call wondermake.inherit_unique,$1,lang)]) \
	$(call wondermake.inherit_unique,$1,cxx_flags[$(call wondermake.inherit_unique,$1,type)]) \
	$(call wondermake.inherit_append,$1,cxx_flags) \
	$(CXXFLAGS) \
	$<
endef

# Command to link object files and produce an executable or shared library file
define wondermake.template.recipee.ld_command # $1 = scope
	$(or $(LD),$(call wondermake.inherit_unique,$1,ld)) \
	$(call wondermake.inherit_unique,$1,ld_flags[$(call wondermake.inherit_unique,$1,type)]) \
	$(call wondermake.inherit_append,$1,ld_flags) \
	$(LDFLAGS) \
	$+ \
	$(patsubst %,$(call wondermake.inherit_unique,$1,ld_libs_pattern),$(call wondermake.inherit_append,$1,ld_libs)) \
	$(LDLIBS)
endef

# Parsers http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2019/p1103r3.pdf
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
	sed -rn 's,^[ 	]*export[ 	]+module[ 	]+([^[ 	;]+)[ 	;],wondermake.module_map[\1] := $*.$1,p' $< >> $@
	sed -rn 's,^[ 	]*export[ 	]+module[ 	]+([^[ 	;]+)[ 	;],wondermake.module_map[\1] := $*.$1,p' $< >> $@
endef

define wondermake.template.recipee.parse_module_keyword # $1 = obj_suffix
	sed -rn 's,^[ 	]*module[ 	]+([^[ 	;]+)[ 	;],$*.$1: $$(wondermake.module_map[\1])\n$*.$1: private module_map = $$(wondermake.module_map[\1]),p' $< >> $@
endef

define wondermake.template.recipee.parse_import_keyword # $1 = obj_suffix
	sed -rn 's,^[         ]*(export[      ]+|)import[     ]+([^[  ;]+)[   ;],$*.$1: $$(wondermake.module_map[\2])\n$*.$1: private module_map += $$(wondermake.module_map[\2]:%=\2=%),p' $< >> $@
endef

define wondermake.template
$(info $(wondermake.template.vars.define))
$(eval $(value wondermake.template.vars.define))
$(info $(wondermake.template.rules))
$(eval $(value wondermake.template.rules))
$(eval $(value wondermake.template.vars.undefine))
endef

define wondermake.template.vars.define

########## Wondermake template for scope $(wondermake.template.scope) #########

wondermake.template.src_dir := $(call wondermake.inherit_unique,$(wondermake.template.scope),src_dir)
wondermake.template.mxx_files := $(shell \
	find $(addprefix $(wondermake.template.src_dir),$($(wondermake.template.scope).src)) \
	-name '' $(patsubst %,-o -name '*.%', \
	$(or \
		$(call wondermake.inherit_unique,$(wondermake.template.scope),mxx_suffix) \
		$(call wondermake.inherit_unique,$(wondermake.template.scope),mxx_suffix[$(call wondermake.inherit_unique,$(wondermake.template.scope),lang)]))) \
	)
wondermake.template.cxx_files := $(shell \
	find $(addprefix $(wondermake.template.src_dir),$($(wondermake.template.scope).src)) \
	-name '' $(patsubst %,-o -name '*.%', \
	$(or \
		$(call wondermake.inherit_unique,$(wondermake.template.scope),cxx_suffix) \
		$(call wondermake.inherit_unique,$(wondermake.template.scope),cxx_suffix[$(call wondermake.inherit_unique,$(wondermake.template.scope),lang)]))) \
	)
wondermake.template.src_files := $(wondermake.template.mxx_files) $(wondermake.template.src_files)
$(foreach s,%.$(suffix $(wondermake.template.src_files)),$(eval vpath %$s $(wondermake.template.src_dir)))
wondermake.template.bmi_suffix := $(call wondermake.inherit_unique,$(wondermake.template.scope),bmi_suffix)
wondermake.template.obj_suffix := $(call wondermake.inherit_unique,$(wondermake.template.scope),obj_suffix)
wondermake.template.name := $(or $($(wondermake.template.scope).name),$(wondermake.template.scope))
wondermake.template.target_file := $(wondermake.template.name:%=$(call wondermake.inherit_unique,$(wondermake.template.scope),binary_file_pattern[$(call wondermake.inherit_unique,$(wondermake.template.scope),type)]))
endef

define wondermake.template.vars.undefine
$(foreach s,%.$(suffix $(wondermake.template.src_files)),$(eval vpath %$s))
undefine wondermake.template.src_dir
undefine wondermake.template.src_files
undefine wondermake.template.cxx_files
undefine wondermake.template.mxx_files
undefine wondermake.template.bmi_suffix
undefine wondermake.template.obj_suffix
undefine wondermake.template.name
undefine wondermake.template.target_file
endef

define wondermake.template.rules

########## Wondermake template for scope $(wondermake.template.scope) #########

wondermake.all: $(wondermake.template.scope)
ifneq '$(wondermake.template.scope)' '$(wondermake.template.name)'
  .PHONY: $(wondermake.template.scope)
  $(wondermake.template.scope): $(wondermake.template.name)
endif
ifneq '$(wondermake.template.name)' '$(wondermake.template.target_file)'
  .PHONY: $(wondermake.template.name)
  $(wondermake.template.name): $(wondermake.template.target_file)
endif

# Rule to preprocess a c++ file
#.SECONDEXPANSION: #| $$(@D)
$(patsubst %,%.ii,$(wondermake.template.cxx_files) $(wondermake.template.mxx_files)): %.ii: %
	mkdir -p $(@D); \
	$(call wondermake.template.recipee.cpp_command,$(wondermake.template.scope))
wondermake.clean += $(patsubst %,%.ii,$(wondermake.template.cxx_files) $(wondermake.template.mxx_files))

# Rule to append extra vars and rules after preprocessing a module interface file
$(patsubst %,%.d,$(wondermake.template.mxx_files)): %.d: %.ii
	$(call wondermake.template.recipee.parse_export_module_keyword,$(wondermake.template.bmi_suffix))
	$(call wondermake.template.recipee.parse_import_keyword,$(wondermake.template.obj_suffix))
wondermake.d += $(patsubst %,%.d,$(wondermake.template.mxx_files))

# Rule to append extra vars and rules after preprocessing a module implementation file
$(patsubst %,%.d,$(wondermake.template.cxx_files)): %.d: %.ii
	$(call wondermake.template.recipee.parse_module_keyword,$(wondermake.template.obj_suffix))
	$(call wondermake.template.recipee.parse_import_keyword,$(wondermake.template.obj_suffix))
wondermake.d += $(patsubst %,%.d,$(wondermake.template.cxx_files))

# Rule to precompile a source file to a binary module interface file
$(patsubst %,%.$(wondermake.template.bmi_suffix),$(basename $(wondermake.template.mxx_files))): %.$(wondermake.template.bmi_suffix): %.ii
	$(call wondermake.template.recipee.mxx_command,$(wondermake.template.scope))

# Rule to compile a source file to an object file
$(patsubst %,%.$(wondermake.template.obj_suffix),$(wondermake.template.cxx_files) $(wondermake.template.mxx_files)): %.$(wondermake.template.obj_suffix): %.ii
	$(call wondermake.template.recipee.cxx_command,$(wondermake.template.scope))

# Rule to link object files and produce an executable or shared library file
$(wondermake.template.target_file): $(patsubst %,%.$(wondermake.template.obj_suffix),$(wondermake.template.cxx_files) $(wondermake.template.mxx_files))
	$(call wondermake.template.recipee.ld_command,$(wondermake.template.scope))
endef

wondermake.clean:
	rm -Rf $(wondermake.clean);
	rmdir -p $(dir $(wondermake.clean)) 2>/dev/null || true

wondermake.escape := $(shell echo -en '\e')

# Scope inheritance support functions
# $1 = scope
wondermake.inherit_root = $(if $($1.inherit),$(call $0,$($1.inherit)),$1)
# $1 = scope, $2 = var
wondermake.inherit_unique = $(or $($1.$2),$(if $($1.inherit),$(call $0,$($1.inherit),$2)))
wondermake.inherit_append = $($1.$2) $(if $($1.inherit),$(call $0,$($1.inherit),$2))
wondermake.inherit_prepend = $(if $($1.inherit),$(call $0,$($1.inherit),$2)) $($1.$2)

# Add a default inheritance on the wondermake scope
$(foreach wondermake.template.scope, $(wondermake), \
	$(if $(call wondermake.find_element,wondermake,$(call wondermake.inherit_root,$(wondermake.template.scope))) \
		,,$(eval $(call wondermake.inherit_root,$(wondermake.template.scope)).inherit := wondermake)))

# Executes the template for each user-declared scope
$(foreach  wondermake.template.scope, $(wondermake), $(eval $(value wondermake.template)))

$(info )
$(info ############# Execution #############)
$(info )

ifneq '$(MAKECMDGOALS)' 'clean' # don't remake the .d files when cleaning
  # include the dynamically generated makefiles (.d files)
  # GNU make will first build (if need be) all of these makefiles
  # before restarting itself to build the actual goal.
  # This will in turn trigger the building of the .ii files, on which the .d files depend.
  # So, preprocessing occurs on the first make phase.
  # Secondary expansion is used to allow variables to be defined out of order.
  # (Without secondary expansion, we have to include $(srcm).d before $(src).d)
  .SECONDEXPANSION:
  -include $(wondermake.d)
endif
