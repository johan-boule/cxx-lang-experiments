# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

###############################################################################
# Overridable programs

wondermake.cxx    := $(or $(call wondermake.user_override,CXX),clang++)
wondermake.cpp    := $(or $(call wondermake.user_override,CPP),$(wondermake.cxx)) #-E
wondermake.ld     := $(or $(call wondermake.user_override,LD),$(wondermake.cxx))
wondermake.ar     := $(or $(call wondermake.user_override,AR),ar)
wondermake.ranlib := $(or $(call wondermake.user_override,RANLIB),$(wondermake.ar) s)

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
# Configuration

# This rule is done only on first build or when changes in the env are detected.
wondermake.configure:: min_required_clang_major_version := 6
wondermake.configure:: wondermake.env.checksum
	@$(call wondermake.echo,configure)
	$(call wondermake.configure.check_toolchain_version,$(min_required_clang_major_version))
	@touch $@

define wondermake.configure.check_toolchain_version # $1 = min_required_clang_major_version
  @set -e; \
  $(call wondermake.echo,check toolchain version); \
  actual_clang_major_version=$$(echo __clang_major__ | $(wondermake.cpp) -E -xc++ - | tail -n1); \
  if ! test $$actual_clang_major_version -ge $1; \
  then \
    printf '%s\n' \
      "requires clang version >= $1. \
      $(firstword $(wondermake.cpp)) is version $$actual_clang_major_version." 1>&2; \
    false; \
  fi
endef
