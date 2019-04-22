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

wondermake.cpp_flags_out_mode = -o@target -E -MD -MF@(target).d -MT@(target) -MP -MJ@(target).compile_commands.json
wondermake.pch_flags_out_mode = -o@target    -MD -MF@(target).d -MT@(target) -MP -MJ@(target).compile_commands.json
wondermake.cxx_flags_out_mode = -o@target -c -MJ@(target).compile_commands.json
wondermake.mxx_flags_out_mode = -o@target --precompile -MJ@(target).compile_commands.json
wondermake.ld_flags_out_mode  = -o@target

# some useful options: -Wmissing-include-dirs -Winvalid-pch -H -fpch-deps -Wp,-v
# g++/clang++ -print-search-dirs ; ld --verbose | grep SEARCH_DIR | tr -s ' ;' \\012
# to print the include search path: g++/clang++ -xc++ /dev/null -E -Wp,-v 2>&1 1>/dev/null | sed -e '/^[^ ]/d' -e 's,^ ,-I,'
wondermake.cpp_flags := -Winvalid-pch
wondermake.cxx_flags := -pipe
wondermake.ld_flags  :=

wondermake.cpp_flags[c++]           := -xc++
wondermake.pch_flags[c++]           := -xc++-header
wondermake.cxx_flags[c++]           := -xc++-cpp-output -fmodules-ts
wondermake.mxx_flags[c++]           := -xc++-module -fmodules-ts
wondermake.cpp_flags[objective-c++] := -xobjective-c++
wondermake.pch_flags[objective-c++] := -xobjective-c++-header
wondermake.cxx_flags[objective-c++] := -xobjective-c++-cpp-output
wondermake.cpp_flags[c]             := -xc
wondermake.pch_flags[c]             := -xc-header
wondermake.cxx_flags[c]             := -xc-cpp-output
wondermake.cpp_flags[objective-c]   := -xobjective-c
wondermake.pch_flags[objective-c]   := -xobjective-c-header
wondermake.cxx_flags[objective-c]   := -xobjective-c-cpp-output

wondermake.cpp_define_pattern := -D%
wondermake.cpp_undefine_pattern := -U%
wondermake.cpp_include_pattern := -include=%
wondermake.cpp_include_path_pattern := -I%
wondermake.cpp_framework_pattern := -F%
wondermake.cxx_module_map_pattern := -fmodule-file=%
wondermake.cxx_module_path_pattern := -fprebuilt-module-path=%
wondermake.ld_lib_path_pattern := -L%
wondermake.ld_lib_pattern := -l%
wondermake.ld_framework_pattern := -framework % # or -Xlinker -f% or -Wl,-f%

wondermake.cxx_pic_flag                := -fPIC
wondermake.cxx_pie_flag                := -fPIE
wondermake.cxx_flags[shared_lib]       := $(wondermake.cxx_pic_flag)
wondermake.ld_flags[static_executable] := -static # we can have both -shared and -static but that's not very useful
wondermake.ld_flags[shared_lib]        := -shared

wondermake.pch_suffix := pch #gch
wondermake.bmi_suffix := pcm
wondermake.obj_suffix := o

wondermake.binary_file_pattern[executable] := %
wondermake.binary_file_pattern[shared_lib] := lib%.so
wondermake.binary_file_pattern[loadable_module] := %.so
wondermake.binary_file_pattern[import_lib] := # none
wondermake.binary_file_pattern[static_lib] := lib%.a
wondermake.binary_file_pattern[objects] := # no link nor archive step
wondermake.binary_file_pattern[headers] := # no link nor archive step

# When using make -j>1 with -O, the compiler cannot know when we're actually on tty
ifdef MAKE_TERMERR
  wondermake.cpp_flags += -fcolor-diagnostics
  wondermake.cxx_flags += -fcolor-diagnostics
  wondermake.ld_flags  += -fcolor-diagnostics
endif

###############################################################################
# Configuration

# This rule is done only on first build or when changes in the env are detected.
ifndef MAKE_RESTARTS # only do this on the first make phase
  wondermake.configure: min_required_clang_major_version := 6 # First version with ISO C++ module TS support
  wondermake.configure: wondermake.env.checksum
	$(call wondermake.announce,configure)
	$(call wondermake.configure.check_toolchain_version,$(min_required_clang_major_version))
	@touch $@

  define wondermake.configure.check_toolchain_version # $1 = min_required_clang_major_version
    $(call wondermake.announce,check toolchain version,requires clang version >= $1)
    @set -e; \
    if ! command -v $(firstword $(wondermake.cpp)) 1>/dev/null; \
    then \
      $(call wondermake.error_shell,requires clang version >= $1. compiler is '$(firstword $(wondermake.cpp))' and cannot be found.); \
    fi; \
    actual_clang_major_version=$$(echo __clang_major__ | $(wondermake.cpp) -E -xc++ - | tail -n1); \
    if ! test $$actual_clang_major_version -ge $1; \
    then \
      $(call wondermake.error_shell,requires clang version >= $1. $(firstword $(wondermake.cpp)) is version $$actual_clang_major_version.); \
    fi; \
    $(call wondermake.trace_shell,$(firstword $(wondermake.cpp)) is version $$actual_clang_major_version.)
  endef
endif
wondermake.clean += wondermake.configure
