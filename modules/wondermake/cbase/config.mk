# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

###############################################################################
# Configuration support

# This rule creates a "signature" of the variables and tools that affects compilation.
# It allows to detect that a rebuild is needed:
# - after changes in the compiler flags,
# - after a different compiler has been selected.
# This rule is always executed.
# This rule updates the target only when the checksum changes.
ifndef MAKE_RESTARTS # only do this on the first make phase
  $(wondermake.bld_dir)wondermake.env.checksum: wondermake.force $(wondermake.bld_dir)wondermake.cxx.env.checksum
	@new=$$( \
		printf '%s\n' \
			"$$(stat -Lc%n\ %Y $(wondermake.bld_dir)wondermake.cxx.env.checksum)" \
			"PATH $(PATH)" \
			"linux/solaris/macosx LD_LIBRARY_PATH $(LD_LIBRARY_PATH)" \
			"macosx DYLD_LIBRARY_PATH $(DYLD_LIBRARY_PATH)" \
			"macosx DYLD_FALLBACK_LIBRARY_PATH $(DYLD_FALLBACK_LIBRARY_PATH)" \
			"hpux SHLIB_PATH $(SHLIB_PATH)" \
			"aix LIBPATH $(LIBPATH)" \
		| md5sum \
	); \
	if test "$$new" != '$(file < $@)'; $(eval wondermake.progress += x) \
	then \
		printf '%s' "$$new" > $@; \
		$(call wondermake.announce_shell,checksum,$@); \
		$(call wondermake.notice_shell,changed); \
	else \
		$(call wondermake.announce_shell,checksum,$@,no change); \
	fi
endif
wondermake.clean += $(wondermake.bld_dir)wondermake.env.checksum

ifndef MAKE_RESTARTS # only do this on the first make phase
  $(wondermake.bld_dir)wondermake.cxx.env.checksum: wondermake.force | $(wondermake.bld_dir)
	@new=$$( \
		printf '%s\n' \
			"stat CPP CXX LD AR RANLIB" \
			"$$(stat -Lc%n\ %Y \
				$$(command -v $(firstword $(wondermake.cpp))) \
				$$(command -v $(firstword $(wondermake.cxx))) \
				$$(command -v $(firstword $(wondermake.ld))) \
				$$(command -v $(firstword $(wondermake.ar))) \
				$$(command -v $(firstword $(wondermake.ranlib))) \
			)" \
			"AR  flags $(wondermake.ar) $(ARFLAGS)" \
			"RANLIB $(wondermake.ranlib)" \
			"min required version $(min_required_clang_major_version)" \
			"GCC_EXEC_PREFIX $(GCC_EXEC_PREFIX)" \
			"COMPILER_PATH $(COMPILER_PATH)" \
			"used by both the compiler and the linker according to man page. see http://www.mingw.org/wiki/LibraryPathHOWTO LIBRARY_PATH $(LIBRARY_PATH)" \
		| md5sum \
	); \
	if test "$$new" != '$(file < $@)'; $(eval wondermake.progress += x) \
	then \
		printf '%s' "$$new" > $@; \
		$(call wondermake.announce_shell,checksum,$@); \
		$(call wondermake.notice_shell,changed); \
	else \
		$(call wondermake.announce_shell,checksum,$@,no change); \
	fi
endif
wondermake.clean += $(wondermake.bld_dir)wondermake.cxx.env.checksum
