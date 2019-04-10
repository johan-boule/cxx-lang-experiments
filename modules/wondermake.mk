#! /usr/bin/make -f

.PHONY: all
all:

wondermake.cpp_suffix[c++] := ii
wondermake.cxx_suffix[c++] := c++ cxx cpp cc C
wondermake.mxx_suffix[c++] := m++ mxx mpp ixx cppm
wondermake.hxx_suffix[c++] := h++ hxx hpp H h
wondermake.cpp_suffix[objective-c++] = $(wondermake.cpp_suffix[c++])
wondermake.cxx_suffix[objective-c++] = $(wondermake.cxx_suffix[c++]) mm
wondermake.mxx_suffix[objective-c++] = $(wondermake.mxx_suffix[c++])
wondermake.hxx_suffix[objective-c++] = $(wondermake.hxx_suffix[c++])
wondermake.cpp_suffix[c] := i
wondermake.cxx_suffix[c] := c
wondermake.hxx_suffix[c] := h
wondermake.cpp_suffix[objective-c] = $(wondermake.cpp_suffix[c])
wondermake.cxx_suffix[objective-c] = $(wondermake.cxx_suffix[c]) m
wondermake.hxx_suffix[objective-c] = $(wondermake.hxx_suffix[c])

wondermake.cpp := clang++
wondermake.cxx := clang++
wondermake.ld  := clang++

wondermake.cpp_flags[c++] := -xc++ -E 
wondermake.cxx_flags[c++] := -xc++-cpp-output -c -fmodules-ts 
wondermake.mxx_flags[c++] := -xc++-module -precompile 
wondermake.cpp_flags[objective-c++] := -xobjective-c++ -E 
wondermake.cxx_flags[objective-c++] := -xobjective-c++-cpp-output -c -fmodules-ts 
wondermake.mxx_flags[objective-c++] := -xobjective-c++-module -precompile 
wondermake.cpp_flags[c] := -xc -E 
wondermake.cxx_flags[c] := -xc-cpp-output -c
wondermake.cpp_flags[objective-c] := -xobjective-c -E 
wondermake.cxx_flags[objective-c] := -xobjective-c-cpp-output -c

wondermake.cxx_flags[shared_lib] := -fPIC
wondermake.ld_flags[shared_lib]  := -shared

wondermake.bmi_suffix := pcm
wondermake.obj_suffix := o

wondermake.binary_file_pattern[exe]        := %.exe
wondermake.binary_file_pattern[shared_lib] := lib%.so
wondermake.binary_file_pattern[import_lib] :=
wondermake.binary_file_pattern(static_lib) := lib%.a

wondermake.ld_libs_pattern := -l%

wondermake.mkdir_target = mkdir -p $(@D)

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
$(if $($1.inherit)
	,$(call $0,$($1.inherit),$2,$3),$(wondermake.$2) $3) \
$($1.$2)
endef

define wondermake.cpp.command # $1 = scope
  @echo $(call wondermake.inherit_unique,$1,cpp,$(CPP)) -o$$@ \
  $(call wondermake.inherit_unique,$1,cpp_flags[$(call wondermake.inherit_unique,$($1.lang))]) \
  $(call wondermake.inherit_unique,$1,cxx_flags[$(call wondermake.inherit_unique,$($1.type))]) \
  $(call wondermake.inherit_append,$1,cpp_flags,$(CPPFLAGS)) \
  $$<
endef

define wondermake.mxx.command # $1 = scope
  @echo $(call wondermake.inherit_unique,$1,cxx,$(CXX)) -o$$@ \
  $(call wondermake.inherit_unique,$1,mxx_flags[$(call wondermake.inherit_unique,$($1.lang))]) \
  $(call wondermake.inherit_unique,$1,cxx_flags[$(call wondermake.inherit_unique,$($1.type))]) \
  $(call wondermake.inherit_append,$1,cxx_flags,$(CXXFLAGS)) \
  $$<
endef

define wondermake.cxx.command # $1 = scope
  @echo $(call wondermake.inherit_unique,$1,cxx,$(CXX)) -o$$@ \
  $(call wondermake.inherit_unique,$1,cxx_flags[$(call wondermake.inherit_unique,$($1.lang))]) \
  $(call wondermake.inherit_unique,$1,cxx_flags[$(call wondermake.inherit_unique,$($1.type))]) \
  $(call wondermake.inherit_append,$1,cxx_flags,$(CXXFLAGS)) \
  $$<
endef

define wondermake.ld_command # $1 = scope
  @echo $(call wondermake.inherit_unique,$1,ld,$(LD)) -o$$@ \
  $(call wondermake.inherit_unique,$1,ld_flags[$(call wondermake.inherit_unique,$($1.type))]) \
  $(call wondermake.inherit_append,$1,ld_flags,$(LDFLAGS)) \
  $$+ \
  $(call wondermake.inherit_append,$1,ld_libs,$(LDLIBS):%=$(call wondermake.inherit_unique,$1,ld_libs_pattern))
endef

define wondermake.template.tmp.begin
	$(eval wondermake.tmp.name := $(or $($(scope).name),$(scope))) \
	$(eval
		wondermake.tmp.target_file := $(wondermake.tmp.name:%=$(call wondermake.inherit_unique,$(scope),binary_file_pattern[$(call wondermake.inherit_unique,$(scope),type)]))
		wondermake.tmp.cxx_files := $(shell find $($(scope).src) -name '' $(patsubst %,-o -name '*.%',$(call wondermake.inherit_unique,$(scope),cxx_suffix[$(call wondermake.inherit_unique,$(scope),lang)])))
		wondermake.tmp.mxx_files := $(shell find $($(scope).src) -name '' $(patsubst %,-o -name '*.%',$(call wondermake.inherit_unique,$(scope),mxx_suffix[$(call wondermake.inherit_unique,$(scope),lang)])))
		wondermake.tmp.bmi_suffix := $(call wondermake.inherit_unique,$(scope),bmi_suffix)
		wondermake.tmp.obj_suffix := $(call wondermake.inherit_unique,$(scope),obj_suffix)
	)
endef

define wondermake.template.tmp.end
$(eval
	undefine wondermake.tmp.name
	undefine wondermake.tmp.target_file
	undefine wondermake.tmp.cxx_files
	undefine wondermake.tmp.mxx_files
	undefine wondermake.tmp.bmi_suffix
	undefine wondermake.tmp.obj_suffix
)
endef

define wondermake.template
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

$(wondermake.tmp.target_file): $(addsuffix .$(wondermake.tmp.obj_suffix),$(wondermake.tmp.cxx_files) $(wondermake.tmp.mxx_files))
	$$(call wondermake.ld_command,$(scope))
\
$(foreach mxx_file, $(wondermake.tmp.mxx_files),
$(basename $(mxx_file)).$(wondermake.tmp.bmi_suffix): $(mxx_file)
	$$(call wondermake.mxx_command,$(scope))
$(mxx_file).$(wondermake.tmp.obj_suffix): $(mxx_file)
	$$(call wondermake.cxx_command,$(scope))
) \
$(foreach cxx_file, $(wondermake.tmp.cxx_files),
$(cxx_file).$(wondermake.tmp.obj_suffix): $(cxx_file)
	$$(call wondermake.cxx_command,$(scope))
)
endef

$(foreach scope, $(wondermake), \
	$(wondermake.template.tmp.begin) \
	$(info $(wondermake.template)) \
	$(eval $(wondermake.template)) \
	$(wondermake.template.tmp.end) \
)

$(info )
$(info ##################################################)
$(info )

#include $(dir $(lastword $(MAKEFILE_LIST)))generic-cxx-module-support.mk
