# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

ifndef wondermake.cbase.commands.included

###############################################################################
# Define the commands ultimately used by the template recipes

ifndef MAKE_RESTARTS # only do this on the first make phase
  # Command to parse ISO C++ module "export module" keywords in an interface file
  define wondermake.cbase.parse_export_module_keyword0 # $1 = scope
    sed -rn 's,^[ 	]*export[ 	]+module[ 	]+([^ 	;]+)[ 	;],wondermake.cbase.module_map[\1].mxx_file := $<,p' $< >> $@.d
  endef

  # Command to parse ISO C++ module "export module" keywords in an interface file
  define wondermake.cbase.parse_export_module_keyword # $1 = bmi file
    sed -rn 's,^[ 	]*export[ 	]+module[ 	]+([^ 	;]+)[ 	;],wondermake.cbase.module_map[\1].bmi_file := $1,p' $< >> $@
  endef

  # Command to parse ISO C++ module "module" keywords in an implementation file
  define wondermake.cbase.parse_module_keyword0 # $1 = scope
    sed -rn 's,^[ 	]*module[ 	]+([^ 	;]+)[ 	;],wondermake.cbase.module_map[\1].scope := $1,p' $< >> $@.d
  endef

  # Command to parse ISO C++ module "module" keywords in an implementation file
  define wondermake.cbase.parse_module_keyword # $1 = obj file
    sed -rn 's,^[ 	]*module[ 	]+([^ 	;]+)[ 	;],$1: $$$$(wondermake.cbase.module_map[\1].bmi_file)\n$1: private module_map = $$(wondermake.cbase.module_map[\1].bmi_file),p' $< >> $@
  endef

  # Command to parse ISO C++ module "import" keywords in an interface or implementation file
  define wondermake.cbase.parse_import_keyword0 # $1 = scope
    sed -rn 's,^[ 	]*(export[ 	]+)?import[ 	]+([^ 	;]+)[ 	;],$1.external_modules_path += $$$$(wondermake.cbase.module_map[\2].mxx_file),p' $< >> $@
    @for import in $$(sed -rn 's,^[ 	]*(export[ 	]+)?import[ 	]+([^ 	;]+)[ 	;],\2,p' $<); \
    do \
      import_last_word=$$(printf '%s' $$import | sed -rn 's,([^.]+)$$,\1 x \1,p'); \
      fuzzy_import='[./]'$$(printf '%s' $$import | sed -r 's,\.,[./],g')'[./]'; \
      printf '%s ' "xxx $1 imports $$import which is" $$(echo $$import_last_word find $(call wondermake.inherit_prepend,$1,include_path) -type f -ipath \'"*$$fuzzy_import*"\'); \
      printf '\n'; \
    done
  endef

  # Command to parse ISO C++ module "import" keywords in an interface or implementation file
  define wondermake.cbase.parse_import_keyword # $1 = targets (obj file, or obj+bmi files)
    sed -rn 's,^[ 	]*(export[ 	]+|)import[ 	]+([^[ 	;]+)[ 	;],$1: $$$$(wondermake.cbase.module_map[\2].bmi_file)\n$1: private module_map += $$(wondermake.cbase.module_map[\2].bmi_file:%=\2=%),p' $< >> $@
  endef

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
endif

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

# Command to compile a c++ source file to an object file
define wondermake.cbase.cxx_command # $1 = scope, $$1 = unsigned flags, $(module_map) is a var private to the object file rule (see .d files)
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

# Command to collect object files into an archive
define wondermake.cbase.ar_command # $1 = scope, $$1 = unsigned flags
  rm -f $$@; \
  $(or $(call wondermake.user_override,AR),$(call wondermake.inherit_unique,$1,ar)) \
  $(call wondermake.inherit_append,$1,ar_flags) \
  $$1 \
  $(call wondermake.user_override,ARFLAGS) \
  $(call wondermake.inherit_unique,$1,ar_flags_out_mode) \
  $$($1.obj_files) \
  $(or $(call wondermake.user_override,RANLIB),$(call wondermake.inherit_unique,$1,ranlib))
endef

###############################################################################
endif # ifndef wondermake.cbase.commands.included
