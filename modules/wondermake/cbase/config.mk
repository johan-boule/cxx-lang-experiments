# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

ifndef wondermake.cbase.config.included

###############################################################################
# Staged install

wondermake.cbase.libs_path := $(wondermake.staged_install)lib

###############################################################################
# Configuration support

###############################################################################
# TODO This is only a placeholder for a real configuration
###############################################################################

include $(dir $(lastword $(MAKEFILE_LIST)))config.unix-elf-clang.mk
wondermake.cbase.inherit := wondermake.cbase.config[unix_elf_clang]

# This rule is done only on first build or when changes in the env are detected.
$(wondermake.bld_dir)wondermake.cbase.configure: min_required_clang_major_version := 6 # First version with ISO C++ module TS support
$(wondermake.bld_dir)wondermake.cbase.configure: $(wondermake.bld_dir)wondermake.cbase.env.unix_elf_clang.checksum
	$(call wondermake.announce,configure toolchain cbase)
	$(call wondermake.cbase.config[unix_elf_clang].check_toolchain_version,$(min_required_clang_major_version))
	@touch $@
wondermake.clean += $(wondermake.bld_dir)wondermake.cbase.configure

ifndef MAKE_RESTARTS # only do this on the first make phase
  $(wondermake.bld_dir)wondermake.cbase.env.unix_elf_clang.checksum: wondermake.force $(wondermake.bld_dir)wondermake.cbase.env.checksum | $(wondermake.bld_dir)
	@new=$$( \
		printf '%s\n' \
			"stat env CPP CXX LD AR RANLIB" \
			"$$(stat -Lc%n\ %Y \
				$(wondermake.bld_dir)wondermake.cbase.env.checksum \
				$$(command -v $(firstword $(wondermake.cbase.config[unix_elf_clang].cpp))) \
				$$(command -v $(firstword $(wondermake.cbase.config[unix_elf_clang].cxx))) \
				$$(command -v $(firstword $(wondermake.cbase.config[unix_elf_clang].ld))) \
				$$(command -v $(firstword $(wondermake.cbase.config[unix_elf_clang].ar))) \
				$$(command -v $(firstword $(wondermake.cbase.config[unix_elf_clang].ranlib))) \
			)" \
			"AR flags $(wondermake.cbase.config[unix_elf_clang].ar) $(ARFLAGS)" \
			"RANLIB $(wondermake.cbase.config[unix_elf_clang].ranlib)" \
			"min required version $(min_required_clang_major_version)" \
			"GCC_EXEC_PREFIX $(GCC_EXEC_PREFIX)" \
			"COMPILER_PATH $(COMPILER_PATH)" \
			"used by both the compiler and the linker according to man page. see http://www.mingw.org/wiki/LibraryPathHOWTO LIBRARY_PATH $(LIBRARY_PATH)" \
		| md5sum \
	); \
	if test "$$new" != '$(shell cat $@ 2>/dev/null)'; \
	then \
		printf '%s' "$$new" > $@; \
		$(call wondermake.announce_shell,checksum,$@); \
		$(call wondermake.notice_shell,changed); \
	else \
		$(call wondermake.announce_shell,checksum,$@,no change); \
	fi
endif
wondermake.clean += $(wondermake.bld_dir)wondermake.cbase.env.unix_elf_clang.checksum

# This rule creates a "signature" of the variables and tools that affects compilation.
# It allows to detect that a rebuild is needed:
# - after changes in the compiler flags,
# - after a different compiler has been selected.
# This rule is always executed.
# This rule updates the target only when the checksum changes.
ifndef MAKE_RESTARTS # only do this on the first make phase
  $(wondermake.bld_dir)wondermake.cbase.env.checksum: wondermake.force | $(wondermake.bld_dir)
	@new=$$( \
		printf '%s\n' \
			"PATH $(PATH)" \
			"native-elf:linux/solaris LD_RUN_PATH $(LD_RUN_PATH)" \
			"native-elf:linux/solaris DT_RUNPATH $(DT_RUNPATH)" \
			"native-elf:linux/solaris DT_RPATH $(DT_RPATH)" \
			"linux/solaris/macosx LD_LIBRARY_PATH $(LD_LIBRARY_PATH)" \
			"macosx DYLD_LIBRARY_PATH $(DYLD_LIBRARY_PATH)" \
			"macosx DYLD_FALLBACK_LIBRARY_PATH $(DYLD_FALLBACK_LIBRARY_PATH)" \
			"hpux SHLIB_PATH $(SHLIB_PATH)" \
			"aix LIBPATH $(LIBPATH)" \
		| md5sum \
	); \
	if test "$$new" != '$(shell cat $@ 2>/dev/null)'; \
	then \
		printf '%s' "$$new" > $@; \
		$(call wondermake.announce_shell,checksum,$@); \
		$(call wondermake.notice_shell,changed); \
	else \
		$(call wondermake.announce_shell,checksum,$@,no change); \
	fi
endif
wondermake.clean += $(wondermake.bld_dir)wondermake.cbase.env.checksum

###############################################################################
endif # ifndef wondermake.cbase.config.included
