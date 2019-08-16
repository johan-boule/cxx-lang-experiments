# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

ifndef wondermake.cbase.config.included
wondermake.cbase.config.makefile_dir := $(dir $(lastword $(MAKEFILE_LIST)))

###############################################################################

include $(wondermake.cbase.config.makefile_dir)src-suffixes.mk

wondermake.cbase.libs_path := $(wondermake.fhs.lib)

###############################################################################
# Choose a toolchain

include $(wondermake.cbase.config.makefile_dir)unix-elf-clang.mk
wondermake.cbase.inherit := wondermake.cbase.config[unix_elf_clang]

###############################################################################
# Overridable programs

wondermake.cbase.pkg_config_prog := $(or $(call wondermake.user_override,PKG_CONFIG),pkg-config)

###############################################################################
# Overridable options

# By default, make shared libs and dynamic executables rather than static
wondermake.cbase.default_type[executable] := dynamic_executable
wondermake.cbase.default_type[lib]        := shared_lib

###############################################################################
# Configuration support

# This rule is done only on first build or when changes in the env are detected.
$(wondermake.bld_dir)wondermake.cbase.configure: $(wondermake.bld_dir)wondermake.cbase.toolchain | $(wondermake.bld_dir)
	$(call $(wondermake.cbase.inherit).check_toolchain_version)
	$(call $(wondermake.cbase.inherit).print_builtin_include_path) > $(wondermake.bld_dir)wondermake.cbase.builtin_include_path
	@touch $@
	@$(call wondermake.announce_shell,configure,toolchain cbase configured,with $(wondermake.cbase.inherit))
wondermake.clean += $(wondermake.bld_dir)wondermake.cbase.configure
wondermake.clean += $(wondermake.bld_dir)wondermake.cbase.builtin_include_path

define $(wondermake.cbase.inherit).builtin_include_path
  $(eval $(wondermake.cbase.inherit).builtin_include_path := $(file < $(wondermake.bld_dir)wondermake.cbase.builtin_include_path))
  $($(wondermake.cbase.inherit).builtin_include_path)
endef
# TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
# TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
# TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
$(wondermake.cbase.inherit).builtin_include_path :=
# TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
# TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
# TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO

$(wondermake.bld_dir)wondermake.cbase.toolchain: $(wondermake.bld_dir)wondermake.cbase.env
$(eval $(call wondermake.write_iif_content_changed_shell,configure,$(wondermake.bld_dir)wondermake.cbase.toolchain, \
	printf '%s\n' \
		"stat: env CPP CXX LD AR RANLIB PKG_CONFIG" \
		"$$$$(stat -Lc'	%Y %n' \
			$$(wondermake.bld_dir)wondermake.cbase.env \
			$$$$(command -v $(firstword $(call wondermake.inherit_unique,wondermake.cbase,cpp))) \
			$$$$(command -v $(firstword $(call wondermake.inherit_unique,wondermake.cbase,cxx))) \
			$$$$(command -v $(firstword $(call wondermake.inherit_unique,wondermake.cbase,ld))) \
			$$$$(command -v $(firstword $(call wondermake.inherit_unique,wondermake.cbase,ar))) \
			$$$$(command -v $(firstword $(call wondermake.inherit_unique,wondermake.cbase,ranlib))) \
			$$$$(command -v $(firstword $(call wondermake.inherit_unique,wondermake.cbase,pkg_config_prog))) \
		)" \
		"min required version: $$(min_required_version)" \
		"cxx env:" \
		"	CPATH=$$$$CPATH" \
		"	CPLUS_INCLUDE_PATH=$$$$CPLUS_INCLUDE_PATH" \
		"	C_INCLUDE_PATH=$$$$C_INCLUDE_PATH" \
		"	OBJC_INCLUDE_PATH=$$$$OBJC_INCLUDE_PATH" \
		"ld env:" \
		"	GNUTARGET=$$$$GNUTARGET" \
		"	LDEMULATION=$$$$LDEMULATION" \
		"	COLLECT_NO_DEMANGLE=$$$$COLLECT_NO_DEMANGLE" \
		"	native-elf (linux/solaris):" \
		"		LD_RUN_PATH=$$$$LD_RUN_PATH" \
		"		DT_RUNPATH=$$$$DT_RUNPATH" \
		"		DT_RPATH=$$$$DT_RPATH" \
		"pkg-config env:" \
		"	PKG_CONFIG_PATH=$$$$PKG_CONFIG_PATH" \
		"	PKG_CONFIG_LIBDIR=$$$$PKG_CONFIG_LIBDIR" \
		"	PKG_CONFIG_DISABLE_UNINSTALLED=$$$$PKG_CONFIG_DISABLE_UNINSTALLED" \
		"	PKG_CONFIG_TOP_BUILD_DIR=$$$$PKG_CONFIG_TOP_BUILD_DIR" \
		"	PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=$$$$PKG_CONFIG_ALLOW_SYSTEM_CFLAGS" \
		"	PKG_CONFIG_ALLOW_SYSTEM_LIBS=$$$$PKG_CONFIG_ALLOW_SYSTEM_LIBS" \
		"	PKG_CONFIG_SYSROOT_DIR=$$$$PKG_CONFIG_SYSROOT_DIR" \
))

# Note that LIBRARY_PATH is used by both the compiler and the linker according to man page. see http://www.mingw.org/wiki/LibraryPathHOWTO
$(eval $(call wondermake.write_iif_content_changed_shell,configure,$(wondermake.bld_dir)wondermake.cbase.env, \
	printf '%s\n' \
		"PATH=$$$$PATH" \
		"linux/solaris/macosx LD_LIBRARY_PATH=$$$$LD_LIBRARY_PATH" \
		"macosx DYLD_LIBRARY_PATH=$$$$DYLD_LIBRARY_PATH" \
		"macosx DYLD_FALLBACK_LIBRARY_PATH=$$$$DYLD_FALLBACK_LIBRARY_PATH" \
		"hpux SHLIB_PATH=$$$$SHLIB_PATH" \
		"aix LIBPATH=$$$$LIBPATH" \
		"LIBRARY_PATH=$$$$LIBRARY_PATH" \
		"GCC_EXEC_PREFIX=$$$$GCC_EXEC_PREFIX" \
		"COMPILER_PATH=$$$$COMPILER_PATH" \
))

# This rule ensures wondermake.auto-clean is called even when specific goals have been given on the make command line.
# Otherwise, auto-clean is only done when the wondermake.default phony target is triggered.
$(wondermake.bld_dir)wondermake.cbase.env: | $(wondermake.bld_dir)wondermake.auto-clean

###############################################################################
undefine wondermake.cbase.config.makefile_dir
endif # ifndef wondermake.cbase.config.included
