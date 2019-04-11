#! /usr/bin/make -f

MAKEFLAGS += --no-builtin-rules --no-builtin-variables

.PHONY: default all test clean debug
.DEFAULT_GOAL := default

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

# Beware that setting --no-builtin-variables via MAKEFLAGS does not entirely get rid of default variables
ifneq '' '$(findstring $(origin CXX), undefined default)'
  # The user calling make has not overridden CXX
  undefine CXX
  wondermake.cxx := $(shell command -v clang++;) # command is a shell built-in, so we need that ';' to force make to really invoke the shell
endif
ifneq '' '$(findstring $(origin CPP), undefined default)'
  # The user calling make has not overridden CPP
  undefine CPP
  wondermake.cpp := $(or $(CXX),$(wondermake.cxx)) #-E
endif
ifneq '' '$(findstring $(origin LD), undefined default)'
  # The user calling make has not overridden LD
  undefine LD
  wondermake.ld := $(or $(CXX),$(wondermake.cxx))
endif

wondermake.cpp_flags := -o$$@ -E -MMD -MF$$(basename $$@).d -MT$$@ -MP # Note: possibly a bug in GNU Make: $$* expands to nothing, hence the $$(basename $$@).
wondermake.cxx_flags := -o$$@ -c
wondermake.mxx_flags := -o$$@ -precompile
wondermake.ld_flags  := -o$$@

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
wondermake.binary_file_pattern[import_lib] :=
wondermake.binary_file_pattern(static_lib) := lib%.a

wondermake.mkdir_target = @echo mkdir -p $$(@D)

# Command to preprocess a c++ file
define wondermake.template.recipee.cpp_command # $1 = scope
  @echo $(or $(CPP),$(call wondermake.inherit_unique,$1,cpp)) \
  $(call wondermake.inherit_unique,$1,cpp_flags[$(call wondermake.inherit_unique,$1,lang)]) \
  $(call wondermake.inherit_unique,$1,cxx_flags[$(call wondermake.inherit_unique,$1,type)]) \
  $(patsubst %,$(call wondermake.inherit_unique,$1,cpp_define_pattern),$(call wondermake.inherit_append,$1,define)) \
  $(patsubst %,$(call wondermake.inherit_unique,$1,cpp_undefine_pattern),$(call wondermake.inherit_append,$1,undefine)) \
  $(patsubst %,$(call wondermake.inherit_unique,$1,cpp_include_pattern),$(call wondermake.inherit_prepend,$1,include)) \
  $(patsubst %,$(call wondermake.inherit_unique,$1,cpp_include_path_pattern),$(call wondermake.inherit_prepend,$1,include_path)) \
  $(call wondermake.inherit_append,$1,cpp_flags) \
  $(CPPFLAGS) \
  $$<
endef

# Command to produce a binary module interface file
define wondermake.template.recipee.mxx_command # $1 = scope
  @echo $(or $(CXX),$(call wondermake.inherit_unique,$1,cxx)) \
  $(call wondermake.inherit_unique,$1,mxx_flags[$(call wondermake.inherit_unique,$1,lang)]) \
  $(call wondermake.inherit_unique,$1,cxx_flags[$(call wondermake.inherit_unique,$1,type)]) \
  $(module_path:%=-fprebuilt-module-path=%) $(module_map:%=-fmodule-file=%) \
  $(call wondermake.inherit_append,$1,cxx_flags) \
  $(CXXFLAGS) \
  $$<
endef

# Command to compile a module implementation or interface file to an object file
define wondermake.template.recipee.cxx_command # $1 = scope
  @echo $(or $(CXX),$(call wondermake.inherit_unique,$1,cxx)) \
  $(call wondermake.inherit_unique,$1,cxx_flags[$(call wondermake.inherit_unique,$1,lang)]) \
  $(call wondermake.inherit_unique,$1,cxx_flags[$(call wondermake.inherit_unique,$1,type)]) \
  $(call wondermake.inherit_append,$1,cxx_flags) \
  $(module_path:%=-fprebuilt-module-path=%) $(module_map:%=-fmodule-file=%) \
  $(CXXFLAGS) \
  $$<
endef

# Command to link object files and produce an executable or shared library file
define wondermake.template.recipee.ld_command # $1 = scope
  @echo $(or $(LD),$(call wondermake.inherit_unique,$1,ld)) \
  $(call wondermake.inherit_unique,$1,ld_flags[$(call wondermake.inherit_unique,$1,type)]) \
  $(call wondermake.inherit_append,$1,ld_flags) \
  $(LDFLAGS) \
  $$+ \
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
  @echo sed -rn 's,^[ 	]*export[ 	]+module[ 	]+([^[ 	;]+)[ 	;],wondermake.module_map[\1] := $$*.$1,p' $$< >> $$@
endef

define wondermake.template.recipee.parse_module_keyword # $1 = obj_suffix
  @echo sed -rn 's,^[ 	]*module[ 	]+([^[ 	;]+)[ 	;],$$*.$1: $$$$$$$$(module_map[\1])\n$$*.$1: private module_map = $$$$(module_map[\1]),p' $$< >> $$@
endef

define wondermake.template.recipee.parse_import_keyword # $1 = obj_suffix
  @echo sed -rn 's,^[         ]*(export[      ]+|)import[     ]+([^[  ;]+)[   ;],$$*.$1: $$$$$$$$(module_map[\2])\n$$*.$1: private module_map += $$$$(module_map[\2]:%=\2=%),p' $$< >> $$@
endef

define wondermake.template
$(eval wondermake.tmp.name := $(or $($(scope).name),$(scope))) \
$(eval
	wondermake.tmp.target_file := $(wondermake.tmp.name:%=$(call wondermake.inherit_unique,$(scope),binary_file_pattern[$(call wondermake.inherit_unique,$(scope),type)]))
	wondermake.tmp.cxx_files := $(shell find $($(scope).src) -name '' $(patsubst %,-o -name '*.%', \
		$(or \
			$(call wondermake.inherit_unique,$(scope),cxx_suffix) \
			$(call wondermake.inherit_unique,$(scope),cxx_suffix[$(call wondermake.inherit_unique,$(scope),lang)]))) \
		)
	wondermake.tmp.mxx_files := $(shell find $($(scope).src) -name '' $(patsubst %,-o -name '*.%', \
		$(or \
			$(call wondermake.inherit_unique,$(scope),mxx_suffix) \
			$(call wondermake.inherit_unique,$(scope),mxx_suffix[$(call wondermake.inherit_unique,$(scope),lang)]))) \
		)
	wondermake.tmp.bmi_suffix := $(call wondermake.inherit_unique,$(scope),bmi_suffix)
	wondermake.tmp.obj_suffix := $(call wondermake.inherit_unique,$(scope),obj_suffix)
) \
$(info $(wondermake.template.rules)) \
$(eval $(wondermake.template.rules)) \
$(eval
	undefine wondermake.tmp.name
	undefine wondermake.tmp.target_file
	undefine wondermake.tmp.cxx_files
	undefine wondermake.tmp.mxx_files
	undefine wondermake.tmp.bmi_suffix
	undefine wondermake.tmp.obj_suffix
)
endef

define wondermake.template.rules
############# $(scope) #############
all: $(scope)
ifneq '$(scope)' '$(wondermake.tmp.name)'
  .PHONY: $(scope)
  $(scope): $(wondermake.tmp.name)
endif
ifneq '$(wondermake.tmp.name)' '$(wondermake.tmp.target_file)'
  .PHONY: $(wondermake.tmp.name)
  $(wondermake.tmp.name): $(wondermake.tmp.target_file)
endif

# Rule to link object files and produce an executable or shared library file
$(wondermake.tmp.target_file): $(patsubst %,%.$(wondermake.tmp.obj_suffix),$(wondermake.tmp.cxx_files) $(wondermake.tmp.mxx_files))
	$(call wondermake.template.recipee.ld_command,$(scope))
\
$(foreach file, $(wondermake.tmp.cxx_files) $(wondermake.tmp.mxx_files),
# Rule to preprocess a c++ file
$(file).ii: $(file)
	$(wondermake.mkdir_target)
	$(call wondermake.template.recipee.cpp_command,$(scope))
# Rule to compile a module implementation or interface file to an object file
$(file).$(wondermake.tmp.obj_suffix): $(file).ii
	$(call wondermake.template.recipee.cxx_command,$(scope))
) \
$(foreach mxx_file, $(wondermake.tmp.mxx_files),
# Rule to produce a binary module interface file
$(basename $(mxx_file)).$(wondermake.tmp.bmi_suffix): $(mxx_file).ii
	$(call wondermake.template.recipee.mxx_command,$(scope))
# Rule to append extra vars and rules after preprocessing a module interface file
$(mxx_file).d: $(mxx_file).ii
	$(call wondermake.template.recipee.parse_export_module_keyword,$(wondermake.tmp.bmi_suffix))
	$(call wondermake.template.recipee.parse_import_keyword,$(wondermake.tmp.obj_suffix))
) \
$(foreach cxx_file, $(wondermake.tmp.cxx_files),
# Rule to append extra vars and rules after preprocessing a module implementation file
$(cxx_file).d: $(cxx_file).ii
	$(call wondermake.template.recipee.parse_module_keyword,$(wondermake.tmp.obj_suffix))
	$(call wondermake.template.recipee.parse_import_keyword,$(wondermake.tmp.obj_suffix))
)
endef

define wondermake.inherit_unique # $1 = scope, $2 = var, $3 = default
$(or
	$($1.$2),
	$(if $($1.inherit)
		,$(call $0,$($1.inherit),$2,$3),$(or $(wondermake.$2),$3)))
endef

define wondermake.inherit_append # $1 = scope, $2 = var, $3 = default
$($1.$2) \
$(if $($1.inherit)
	,$(call $0,$($1.inherit),$2,$3),$(wondermake.$2) $3)
endef

define wondermake.inherit_prepend # $1 = scope, $2 = var, $3 = default
$3 $(wondermake.$2) \
$(if $($1.inherit)
	,$(call $0_impl_detail,$($1.inherit),$2)) \
$($1.$2)
endef

define wondermake.inherit_prepend_impl_detail # $1 = scope, $2 = var, $3 = default
$(if $($1.inherit)
	,$(call $0,$($1.inherit),$2)) \
$($1.$2)
endef

$(foreach scope, $(wondermake), $(wondermake.template))

$(info )
$(info ##################################################)
$(info )

#include $(dir $(lastword $(MAKEFILE_LIST)))generic-cxx-module-support.mk
