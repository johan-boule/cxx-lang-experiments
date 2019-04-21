# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

###############################################################################
# Source files suffixes

wondermake.cpp_suffix[c]   := i
wondermake.cxx_suffix[c]   := c
wondermake.hxx_suffix[c]   := h
wondermake.cpp_suffix[c++] := ii
wondermake.cxx_suffix[c++] := c++ cxx cpp cc C
wondermake.hxx_suffix[c++] := h++ hxx hpp hh H $(wondermake.hxx_suffix[c])
wondermake.mxx_suffix[c++] := m++ mxx mpp ixx cppm
wondermake.cpp_suffix[objective-c]   := $(wondermake.cpp_suffix[c])
wondermake.cxx_suffix[objective-c]   := $(wondermake.cxx_suffix[c]) m
wondermake.hxx_suffix[objective-c]   := $(wondermake.hxx_suffix[c])
wondermake.cpp_suffix[objective-c++] := $(wondermake.cpp_suffix[c++])
wondermake.cxx_suffix[objective-c++] := $(wondermake.cxx_suffix[c++]) mm
wondermake.hxx_suffix[objective-c++] := $(wondermake.hxx_suffix[c++])
#wondermake.mxx_suffix[objective-c++] := $(wondermake.mxx_suffix[c++])

###############################################################################
# Configuration support

# This rule creates a "signature" of the variables and tools that affects compilation.
# It allows to detect that a rebuild is needed:
# - after changes in the compiler flags,
# - after a different compiler has been selected.
# This rule is always executed.
# This rule updates the target only when the checksum changes.
ifndef MAKE_RESTARTS # only do this on the first make phase
  wondermake.env.checksum: wondermake.force
	$(call wondermake.info,checksum $@)
	@new=$$( \
		printf '%s\n' \
			"PATH $(PATH)" \
			"linux/solaris/macosx LD_LIBRARY_PATH $(LD_LIBRARY_PATH)" \
			"macosx DYLD_LIBRARY_PATH $(DYLD_LIBRARY_PATH)" \
			"macosx DYLD_FALLBACK_LIBRARY_PATH $(DYLD_FALLBACK_LIBRARY_PATH)" \
			"hpux SHLIB_PATH $(SHLIB_PATH)" \
			"aix LIBPATH $(LIBPATH)" \
		| md5sum \
	); \
	if test "$$new" != '$(file < $@)'; \
	then \
		printf '%s' "$$new" > $@; \
		$(call wondermake.notice_shell,changed); \
	else \
		$(call wondermake.trace_shell,no change); \
	fi
endif
wondermake.clean += wondermake.env.checksum

ifndef MAKE_RESTARTS # only do this on the first make phase
  wondermake.env.checksum: wondermake.cxx.env.checksum
  wondermake.cxx.env.checksum: wondermake.force
	$(call wondermake.info,checksum $@)
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
	if test "$$new" != '$(file < $@)'; \
	then \
		printf '%s' "$$new" > $@; \
		$(call wondermake.notice_shell,changed); \
	else \
		$(call wondermake.trace_shell,no change); \
	fi
endif
wondermake.clean += wondermake.cxx.env.checksum
