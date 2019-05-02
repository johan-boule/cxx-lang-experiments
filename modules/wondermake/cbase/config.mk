# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

ifndef wondermake.cbase.config.included

###############################################################################
# Staged install

wondermake.cbase.libs_path := $(wondermake.staged_install)lib

###############################################################################
# Overridable programs

wondermake.cbase.pkg_config_prog := $(or $(call wondermake.user_override,PKG_CONFIG),pkg-config)

###############################################################################
# Configuration support

###############################################################################
# TODO This is only a placeholder for a real configuration
###############################################################################

include $(dir $(lastword $(MAKEFILE_LIST)))config.unix-elf-clang.mk
wondermake.cbase.inherit := wondermake.cbase.config[unix_elf_clang]

# By default, make shared libs and dynamic executables rather than static
wondermake.cbase.default_type[executable] := dynamic_executable
wondermake.cbase.default_type[lib]        := shared_lib
wondermake.cbase.default_executable_type := dynamic_executable
wondermake.cbase.default_lib_type        := shared_lib

wondermake.cbase.cxx_flags[executable]           := $(call wondermake.inherit_append,wondermake.cbase,cxx_flags[$(wondermake.cbase.default_executable_type)])
wondermake.cbase.cxx_flags[lib]                  := $(call wondermake.inherit_append,wondermake.cbase,cxx_flags[$(wondermake.cbase.default_lib_type)])
wondermake.cbase.ld_flags[executable]            := $(call wondermake.inherit_append,wondermake.cbase,ld_flags[$(wondermake.cbase.default_executable_type)])
wondermake.cbase.ld_flags[lib]                   := $(call wondermake.inherit_append,wondermake.cbase,ld_flags[$(wondermake.cbase.default_lib_type)])
wondermake.cbase.binary_file_pattern[executable] := $(call wondermake.inherit_unique,wondermake.cbase,binary_file_pattern[$(wondermake.cbase.default_executable_type)])
wondermake.cbase.binary_file_pattern[lib]        := $(call wondermake.inherit_unique,wondermake.cbase,binary_file_pattern[$(wondermake.cbase.default_lib_type)])

# This rule is done only on first build or when changes in the env are detected.
$(wondermake.bld_dir)wondermake.cbase.configure: gcc_min_required_version   := 9 # First version with ISO C++ module TS support
$(wondermake.bld_dir)wondermake.cbase.configure: clang_min_required_version := 6 # First version with ISO C++ module TS support
$(wondermake.bld_dir)wondermake.cbase.configure: $(wondermake.bld_dir)wondermake.cbase.config
	$(call wondermake.announce,configure,toolchain cbase)
	$(call wondermake.cbase.config[unix_elf_clang].check_toolchain_version,$(clang_min_required_version))
	@touch $@
wondermake.clean += $(wondermake.bld_dir)wondermake.cbase.configure

ifndef MAKE_RESTARTS # only do this on the first make phase
  $(wondermake.bld_dir)wondermake.cbase.config: wondermake.force $(wondermake.bld_dir)wondermake.cbase.env | $(wondermake.bld_dir)
	@new=$$( \
		printf '%s\n' \
			"stat: env CPP CXX LD AR RANLIB PKG_CONFIG" \
			"$$(stat -Lc'	%Y %n' \
				$(wondermake.bld_dir)wondermake.cbase.env \
				$$(command -v $(firstword $(call wondermake.inherit_unique,wondermake.cbase,cpp))) \
				$$(command -v $(firstword $(call wondermake.inherit_unique,wondermake.cbase,cxx))) \
				$$(command -v $(firstword $(call wondermake.inherit_unique,wondermake.cbase,ld))) \
				$$(command -v $(firstword $(call wondermake.inherit_unique,wondermake.cbase,ar))) \
				$$(command -v $(firstword $(call wondermake.inherit_unique,wondermake.cbase,ranlib))) \
				$$(command -v $(firstword $(call wondermake.inherit_unique,wondermake.cbase,pkg_config_prog))) \
			)" \
			"min required version:" \
			"	gcc: $(gcc_min_required_version)" \
			"	clang: $(clang_min_required_version)" \
			"cxx env:" \
				"	CPATH=$(CPATH)" \
				"	CPLUS_INCLUDE_PATH=$(CPLUS_INCLUDE_PATH)" \
				"	C_INCLUDE_PATH=$(C_INCLUDE_PATH)" \
			"ld env:" \
				"	GNUTARGET=$(GNUTARGET)" \
				"	LDEMULATION=$(LDEMULATION)" \
				"	COLLECT_NO_DEMANGLE=$(COLLECT_NO_DEMANGLE)" \
				"	native-elf (linux/solaris):" \
				"		LD_RUN_PATH=$(LD_RUN_PATH)" \
				"		DT_RUNPATH=$(DT_RUNPATH)" \
				"		DT_RPATH=$(DT_RPATH)" \
			"pkg-config env:" \
				"	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH)" \
				"	PKG_CONFIG_LIBDIR=$(PKG_CONFIG_LIBDIR)" \
				"	PKG_CONFIG_DISABLE_UNINSTALLED=$(PKG_CONFIG_DISABLE_UNINSTALLED)" \
				"	PKG_CONFIG_TOP_BUILD_DIR=$(PKG_CONFIG_TOP_BUILD_DIR)" \
				"	PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=$(PKG_CONFIG_ALLOW_SYSTEM_CFLAGS)" \
				"	PKG_CONFIG_ALLOW_SYSTEM_LIBS=$(PKG_CONFIG_ALLOW_SYSTEM_LIBS)" \
				"	PKG_CONFIG_SYSROOT_DIR=$(PKG_CONFIG_SYSROOT_DIR)" \
	); \
	if test "$$new" = "$$(cat $@ 2>/dev/null)"; \
	then \
		$(if $(wondermake.verbose),$(call wondermake.announce_shell,configure,compare $@,no change),:); \
	else \
		$(call wondermake.announce_shell,configure,compare $@); \
		if test -e $@; \
		then \
			$(call wondermake.notice_shell,changed:); \
			$(call wondermake.if_not_silent_shell,printf '%s\n' "$$new" | diff -y -W$$(tput cols) $@ -); \
		else \
			$(call wondermake.if_not_silent_shell,printf '%s\n' "$$new"); \
		fi; \
		printf '%s\n' "$$new" > $@; \
	fi
endif
wondermake.clean += $(wondermake.bld_dir)wondermake.cbase.config

ifndef MAKE_RESTARTS # only do this on the first make phase
  $(wondermake.bld_dir)wondermake.cbase.env: wondermake.force | $(wondermake.bld_dir) # Note: LIBRARY_PATH used by both the compiler and the linker according to man page. see http://www.mingw.org/wiki/LibraryPathHOWTO
	@new=$$( \
		printf '%s\n' \
			"PATH=$(PATH)" \
			"linux/solaris/macosx LD_LIBRARY_PATH=$(LD_LIBRARY_PATH)" \
			"macosx DYLD_LIBRARY_PATH=$(DYLD_LIBRARY_PATH)" \
			"macosx DYLD_FALLBACK_LIBRARY_PATH=$(DYLD_FALLBACK_LIBRARY_PATH)" \
			"hpux SHLIB_PATH=$(SHLIB_PATH)" \
			"aix LIBPATH=$(LIBPATH)" \
			"LIBRARY_PATH=$(LIBRARY_PATH)" \
			"GCC_EXEC_PREFIX=$(GCC_EXEC_PREFIX)" \
			"COMPILER_PATH=$(COMPILER_PATH)" \
	); \
	if test "$$new" = "$$(cat $@ 2>/dev/null)"; \
	then \
		$(if $(wondermake.verbose),$(call wondermake.announce_shell,configure,compare $@,no change),:); \
	else \
		$(call wondermake.announce_shell,configure,compare $@); \
		if test -e $@; \
		then \
			$(call wondermake.notice_shell,changed:); \
			$(call wondermake.if_not_silent_shell,printf '%s\n' "$$new" | diff -y -W$$(tput cols) $@ -); \
		else \
			$(call wondermake.if_not_silent_shell,printf '%s\n' "$$new"); \
		fi; \
		printf '%s\n' "$$new" > $@; \
	fi
endif
wondermake.clean += $(wondermake.bld_dir)wondermake.cbase.env

###############################################################################
endif # ifndef wondermake.cbase.config.included
