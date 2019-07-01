# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

ifndef wondermake.cbase.config.unix_elf_clang.included

###############################################################################
# Overridable programs

wondermake.cbase.config[unix_elf_clang].cxx    := $(or $(call wondermake.user_override,CXX),clang++)
wondermake.cbase.config[unix_elf_clang].cpp    := $(or $(call wondermake.user_override,CPP),$(wondermake.cbase.config[unix_elf_clang].cxx)) # -E
wondermake.cbase.config[unix_elf_clang].ld     := $(or $(call wondermake.user_override,LD),$(wondermake.cbase.config[unix_elf_clang].cxx))
wondermake.cbase.config[unix_elf_clang].ar     := $(or $(call wondermake.user_override,AR),ar)
wondermake.cbase.config[unix_elf_clang].ranlib := $(call wondermake.user_override,RANLIB) # empty default because done through 'ar s'

###############################################################################
# Toolchain configuration variables

wondermake.cbase.config[unix_elf_clang].cpp_flags_out_mode = -o$$@ -E -MD -MF$$@.d -MT$$@ -MP -MJ$$@.compile_commands.json
wondermake.cbase.config[unix_elf_clang].pch_flags_out_mode = -o$$@    -MD -MF$$@.d -MT$$@ -MP -MJ$$@.compile_commands.json
wondermake.cbase.config[unix_elf_clang].cxx_flags_out_mode = -o$$@ -c -MJ$$@.compile_commands.json
wondermake.cbase.config[unix_elf_clang].mxx_flags_out_mode = -o$$@ --precompile -MJ$$@.compile_commands.json
wondermake.cbase.config[unix_elf_clang].ld_flags_out_mode  = -o$$@
wondermake.cbase.config[unix_elf_clang].ar_flags_out_mode  =   $$@

# some useful options: -Wmissing-include-dirs -Winvalid-pch -H -fpch-deps -Wp,-v
# g++/clang++ -print-search-dirs ; ld --verbose | grep SEARCH_DIR | tr -s ' ;' \\012
# to print the include search path: g++/clang++ -xc++ /dev/null -E -Wp,-v 2>&1 1>/dev/null | sed -e '/^[^ ]/d' -e 's,^ ,-I,'
wondermake.cbase.config[unix_elf_clang].cpp_flags := -Winvalid-pch
wondermake.cbase.config[unix_elf_clang].cxx_flags := -pipe
wondermake.cbase.config[unix_elf_clang].ar_flags  := qcDs

# commit 8af8b8611c5daee5f04eac93e9315368f42ab70e
# Author: Richard Smith <richard-llvm@metafoo.co.uk>
# Date:   Thu Apr 11 21:18:23 2019 +0000
# 
#     [C++20] Implement context-sensitive header-name lexing and pp-import parsing in the preprocessor.
# 
#     llvm-svn: 358231

wondermake.cbase.config[unix_elf_clang].cpp_flags[c++]           := -xc++ -std=c++2a -fmodules-ts
wondermake.cbase.config[unix_elf_clang].pch_flags[c++]           := -xc++-header -std=c++2a -fmodules-ts
wondermake.cbase.config[unix_elf_clang].cxx_flags[c++]           := -xc++-cpp-output -std=c++2a -fmodules-ts
wondermake.cbase.config[unix_elf_clang].mxx_flags[c++]           := -xc++-module -std=c++2a -fmodules-ts
wondermake.cbase.config[unix_elf_clang].cpp_flags[objective-c++] := -xobjective-c++
wondermake.cbase.config[unix_elf_clang].pch_flags[objective-c++] := -xobjective-c++-header
wondermake.cbase.config[unix_elf_clang].cxx_flags[objective-c++] := -xobjective-c++-cpp-output
wondermake.cbase.config[unix_elf_clang].cpp_flags[c]             := -xc
wondermake.cbase.config[unix_elf_clang].pch_flags[c]             := -xc-header
wondermake.cbase.config[unix_elf_clang].cxx_flags[c]             := -xc-cpp-output
wondermake.cbase.config[unix_elf_clang].cpp_flags[objective-c]   := -xobjective-c
wondermake.cbase.config[unix_elf_clang].pch_flags[objective-c]   := -xobjective-c-header
wondermake.cbase.config[unix_elf_clang].cxx_flags[objective-c]   := -xobjective-c-cpp-output

wondermake.cbase.config[unix_elf_clang].cpp_define_pattern := -D%
wondermake.cbase.config[unix_elf_clang].cpp_undefine_pattern := -U%
wondermake.cbase.config[unix_elf_clang].cpp_include_pattern := -include=%
wondermake.cbase.config[unix_elf_clang].cpp_include_path_pattern := -I%
wondermake.cbase.config[unix_elf_clang].cpp_framework_pattern := -F%
wondermake.cbase.config[unix_elf_clang].cxx_module_map_pattern := -fmodule-file=%
wondermake.cbase.config[unix_elf_clang].cxx_module_path_pattern := -fprebuilt-module-path=%
wondermake.cbase.config[unix_elf_clang].ld_lib_path_pattern := -L%
wondermake.cbase.config[unix_elf_clang].ld_lib_pattern := -l%
wondermake.cbase.config[unix_elf_clang].ld_framework_pattern := -framework % # or -Xlinker -f% or -Wl,-f%

wondermake.cbase.config[unix_elf_clang].cxx_pic_flag                 := -fPIC
wondermake.cbase.config[unix_elf_clang].cxx_pie_flag                 := -fPIE
wondermake.cbase.config[unix_elf_clang].cxx_flags[shared_lib]        := $(wondermake.cbase.config[unix_elf_clang].cxx_pic_flag)
wondermake.cbase.config[unix_elf_clang].ld_flags[shared_lib]         := -shared -Wl,-rpath=\$$$$ORIGIN
wondermake.cbase.config[unix_elf_clang].ld_flags[dynamic_executable] := -Wl,-rpath-link=$(wondermake.fhs.lib) -Wl,-rpath=\$$$$ORIGIN/$(wondermake.fhs.bin_to_lib)
wondermake.cbase.config[unix_elf_clang].ld_flags[static_executable]  := -static

wondermake.cbase.config[unix_elf_clang].ld_flags_soname = -Wl,-h,$$(@F).$(firstword $(subst ., ,$(call wondermake.inherit_unique,$1,version)))

wondermake.cbase.config[unix_elf_clang].cxx_flags[loadable_module]   := $(wondermake.cbase.config[unix_elf_clang].cxx_flags[shared_lib])
wondermake.cbase.config[unix_elf_clang].ld_flags[loadable_module]    := $(wondermake.cbase.config[unix_elf_clang].ld_flags[shared_lib])

wondermake.cbase.config[unix_elf_clang].pch_suffix := pch
wondermake.cbase.config[unix_elf_clang].bmi_suffix := pcm
wondermake.cbase.config[unix_elf_clang].obj_suffix := o

wondermake.cbase.config[unix_elf_clang].out_file_pattern[dynamic_executable] := $(wondermake.fhs.bin)%
wondermake.cbase.config[unix_elf_clang].out_file_pattern[static_executable]  := $(wondermake.fhs.bin)%
wondermake.cbase.config[unix_elf_clang].out_file_pattern[shared_lib]         := $(wondermake.fhs.lib)lib%.so
wondermake.cbase.config[unix_elf_clang].out_file_pattern[import_lib]         := # none
wondermake.cbase.config[unix_elf_clang].out_file_pattern[loadable_module]    := $(wondermake.fhs.lib)%.so
wondermake.cbase.config[unix_elf_clang].out_file_pattern[static_lib]         := $(wondermake.fhs.lib)lib%.a

# When using make -j>1 -O, the compiler cannot know when we're actually on tty
ifdef MAKE_TERMERR
  wondermake.cbase.config[unix_elf_clang].cpp_flags_unsigned := -fcolor-diagnostics
  wondermake.cbase.config[unix_elf_clang].cxx_flags_unsigned := -fcolor-diagnostics
  wondermake.cbase.config[unix_elf_clang].ld_flags_unsigned  := -fcolor-diagnostics
endif

###############################################################################
# Configuration

define wondermake.cbase.config[unix_elf_clang].check_toolchain_version # $1 = min_required_clang_major_version
  $(call wondermake.announce,configure,check clang version,requires clang version >= $1)
  @set -e && \
  if ! command -v $(firstword $(wondermake.cbase.config[unix_elf_clang].cpp)) 1>/dev/null; \
  then \
    $(call wondermake.error_shell,clang version >= $1 is required. compiler is '$(firstword $(wondermake.cbase.config[unix_elf_clang].cpp))' and cannot be found.); \
  fi; \
  actual_clang_major_version=$$(echo __clang_major__ | $(wondermake.cbase.config[unix_elf_clang].cpp) -E -xc++ - | tail -n1); \
  if test $$actual_clang_major_version = __clang_major__; \
  then \
    $(call wondermake.error_shell,clang version >= $1 is required. compiler is '$(firstword $(wondermake.cbase.config[unix_elf_clang].cpp))' and does not define '__clang_major__'. \
      Note: '$(wondermake.cbase.config[unix_elf_clang].cpp) --version' reads \"$(shell $(wondermake.cbase.config[unix_elf_clang].cpp) --version 2>/dev/null)\" \
      Note: '$(wondermake.cbase.config[unix_elf_clang].cpp) -dumpversion' reads \"$(shell $(wondermake.cbase.config[unix_elf_clang].cpp) -dumpversion 2>/dev/null)\"); \
  fi; \
  if test $$actual_clang_major_version -lt $1; \
  then \
    $(call wondermake.error_shell,clang version >= $1 is required. $(firstword $(wondermake.cbase.config[unix_elf_clang].cpp)) is version $$actual_clang_major_version.); \
  fi; \
  $(call wondermake.trace_shell,$(firstword $(wondermake.cbase.config[unix_elf_clang].cpp)) is version $$actual_clang_major_version.)
endef

###############################################################################
endif # ifndef wondermake.cbase.config.unix_elf_clang.included
