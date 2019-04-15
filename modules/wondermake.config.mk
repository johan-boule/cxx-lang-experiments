# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

###############################################################################
# Pick one

include $(dir $(lastword $(MAKEFILE_LIST)))wondermake.config.unix-elf-clang.mk

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

wondermake.configure:: wondermake.env.checksum
	@$(call wondermake.echo,configure)

# This rule updates the target when the source content has actually changed, regardless of timestamp.
wondermake.%.checksum: $(if $(MAKE_RESTARTS),,wondermake.%) # only do this on the first make phase
	@set -e; \
	$(call wondermake.echo,checksum $+ to $@); \
	md5sum $+ > $@.new; \
	if ! test -e $@ || ! cmp $@ $@.new; \
	then \
		$(call wondermake.echo,checksum $+ to $@: changed); \
		mv $@.new $@; \
	else \
		$(call wondermake.echo,checksum $+ to $@: no change); \
		rm $@.new; \
	fi

# This rule creates a "signature" of the variables and tools that affects compilation.
# It allows to detect that a rebuild is needed:
# - after changes in the compiler flags,
# - after a different compiler has been selected.
# This rule is always executed.
.PHONY: wondermake.force
wondermake.env: $(if $(MAKE_RESTARTS),,wondermake.force) # only do this on the first make phase
	@$(call wondermake.echo,dump program timestamps and variables to $@); \
	printf '%s\n' \
		"stat makefile CPP CXX LD AR RANLIB" \
		"$$(stat -Lc%n\ %Y \
		  $(sort $(filter-out $(wondermake.dynamically_generated_makefiles),$(MAKEFILE_LIST))) \
		  $$(command -v $(firstword $(wondermake.cpp))) \
		  $$(command -v $(firstword $(wondermake.cxx))) \
		  $$(command -v $(firstword $(wondermake.ld))) \
		  $$(command -v $(firstword $(wondermake.ar))) \
		  $$(command -v $(firstword $(wondermake.ranlib))) \
		)" \
		"CPP flags $(wondermake.cpp) $(CPPFLAGS)" \
		"CXX flags $(wondermake.cxx) $(CXXFLAGS)" \
		"LD  flags $(wondermake.ld) $(LDFLAGS) $(LDLIBS)" \
		"AR  flags $(wondermake.ar) $(ARFLAGS)" \
		"RANLIB $(wondermake.ranlib)" \
		"min required version $(min_required_clang_major_version)" \
	> $@

wondermake.clean::
	rm -f wondermake.env wondermake.env.checksum wondermake.env.checksum.new wondermake.configure
