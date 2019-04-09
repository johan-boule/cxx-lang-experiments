#! /usr/bin/make -f

.PHONY: all
all:

wondermake.src_suffix[c++][cpp] := .ii
wondermake.src_suffix[c++][cxx] := .c++ .cxx .cpp .cc .C
wondermake.src_suffix[c++][mxx] := .m++ .mxx .mpp .ixx .cppm

wondermake.cpp := clang++ -E
wondermake.cxx := clang++
wondermake.ld  := clang++

wondermake.ld_libs_pattern := -l%
wondermake.lang_flag[c++][cpp] := -xc++
wondermake.lang_flag[c++][cxx] := -xc++-cpp-output
wondermake.lang_flag[c++][mxx] := -xc++-module

wondermake.cpp_flags[shared_lib] := -fPIC
wondermake.cxx_flags[shared_lib] := -fPIC
wondermake.ld_flags[shared_lib]  := -shared

wondermake.binary_file_pattern[exe]        := %
wondermake.binary_file_pattern[shared_lib] := lib%.so
wondermake.binary_file_pattern[import_lib] :=
wondermake.binary_file_pattern(static_lib) := lib%.a

wondermake.bmi_suffix := pcm
wondermake.obj_suffix := o

wondermake.mkdir_target = mkdir -p $(@D)

define wondermake.inherit # $1 = scope, $2 = var, $3 = default
$(or
	$($1.$2),
	$(if $($1.inherit)
		,$(call $0,$($1.inherit),$2,$3),$(or $(wondermake.$2),$3)))
endef

define wondermake.cpp.command # $1 = target
  @echo $(call wondermake.inherit,$1,cpp,$(CPP))
  $(call wondermake.inherit,$1,cpp_flags[$(call wondermake.inherit,$($1.type))])
  $(wondermake.cpp_flags[$(wondermake[$1].binary_type)]) \
  -o$$@ \
  $(wondermake[$(wondermake[$1].inherit)].cpp.flags) \
  $(wondermake[$1].cpp.flags) \
  $(CPPFLAGS) \
  $(wondermake.lang.pattern:%=$(or \
    $(wondermake.targets[$1].src.lang), \
    $(wondermake.inherit[$(wondermake.targets[$1].inherit)].src.lang), \
    $(wondermake.src.lang) \
  )) $$<
endef

define wondermake.mxx.command # $1 = target
  @echo $(or \
    $(wondermake.target[$1].cxx), \
   $(wondermake.inherit[$(wondermake.targets[$1].inherit)].cxx), \
    $(wondermake.cxx) \
    $(CXX) \
  ) \
  -precompile \
  $(wondermake.types[$(wondermake.targets[$1].type)].cxxflags) \
  -o$$@ \
  $(wondermake.inherit[$(wondermake.targets[$1].inherit)].cxxflags) \
  $(wondermake.targets[$1].cxxflags) \
  $(CXXFLAGS) \
  -x$(or \
    $(wondermake.target[$1].lang), \
    $(wondermake.inherit[$(wondermake.targets[$1].inherit)].lang), \
    $(wondermake.lang) \
  )-module $$<
endef

define wondermake.cxx.command # $1 = scope
  @echo $(or \
    $(wondermake.target[$1].cxx), \
    $(wondermake.inherit[$(wondermake.targets[$1].inherit)].cxx), \
    $(wondermake.cxx) \ 
    $(CXX) \
  ) \
  -c -fmodules-ts \
  $(wondermake.types[$(wondermake.targets[$1].type)].cxxflags) \
  -o$$@ \
  $(wondermake.inherit[$(wondermake.targets[$1].inherit)].cxxflags) \
  $(wondermake.targets[$1].cxxflags) \
  $(CXXFLAGS) \
  -x$(or \
      $($1.lang), \
      $(wondermake[$($1.inherit)].lang), \
      $(wondermake.lang) \
  )-cpp-output $$<
endef

define wondermake.ld_command # $1 = scope
  @echo $(or \
    $($1.ld), \
    $(wondermake[$($1.inherit)].ld), \
    $(wondermake.ld) \
    $(LD) \
  ) \
  $(wondermake.ld_flags[$($1.type)]) \
  -o$$@ \
  $(wondermake[$($1.inherit)].ldflags) \
  $($1.ldflags) \
  $(LDFLAGS) \
  $$+ \
  $(wondermake[$($($1.inherit).ldlibs)]) \
  $($1.ldlibs) \
  $(LDLIBS)
endef

define wondermake.template.with_simple_var_names

############# $(scope) #############
.PHONY: $(scope)
all: $(scope)
$(scope): $(target_file)
$(target_file): $(addsuffix $(wondermake.obj_suffix),$(cxx_files) $(mxx_files))
	$$(call wondermake.ld_command,$(scope))
$(foreach cxx_file, $(cxx_files),
$(cxx_file).o: $(cxx_file)
	$$(call wondermake.compile_command,$(scope)))
$(foreach mxx_file, $(mxx_files),
$(mxx_file)$(wondermake.obj_suffix): $(mxx_file)
	$$(call wondermake.compile_command,$(scope)))
$(mxx_file:%=$(wondermake.bmi_suffix)): $(mxx_file)
	$$(call wondermake.precompile_command,$(scope)))
endef

define wondermake.template
$(eval target_file := $(target:%=$(wondermake.binary_file_pattern[$($(scope).binary_type)])) \
$(eval cxx_files := $(shell find $($(scope).src) \( -name '' $(wondermake.src_suffix[cxx]:%=-o -name '*%') \))) \
$(eval mxx_files := $(shell find $($(scope).src) \( -name '' $(wondermake.src_suffix[mxx]:%=-o -name '*%') \))) \
$(wondermake.template_with_simple_var_names) \
$(eval undefine target_file) \
$(eval undefine cxx_files) \
$(eval undefine mxx_files)
endef

$(foreach scope, $(wondermake:%=wondermake[%]), \
	$(info $(wondermake.template)) \
	$(eval $(wondermake.template)) \
)

$(info )
$(info ##################################################)
$(info )

#include $(dir $(lastword $(MAKEFILE_LIST)))generic-cxx-module-support.mk
