# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

ifndef wondermake.init.included

###############################################################################
# Phony targets

.PHONY: wondermake.default wondermake.all
wondermake.all: wondermake.default

###############################################################################
# Create accumulator vars as immediate

wondermake.second_expansion_rules := # this is an immediate var
wondermake.dynamically_generated_makefiles := # this is an immediate var
wondermake.dynamically_generated_makefiles.included := # this is an immediate var

###############################################################################
# Directory under which all derived files are put.

ifndef wondermake.bld_dir
  # If make is called directly from the source dir, we arrange for building in a subdir.
  # Appart from having the benefit of not polluting the source dir,
  # it also prevents any implicit rule defined outside of wondermake from kicking in and interfering.
  ifneq '' '$(call wondermake.equals,$(realpath $(dir $(firstword $(MAKEFILE_LIST)))),$(realpath $(CURDIR)))'
    wondermake.bld_dir := ++wondermake-build/
  endif
endif

ifneq '' '$(wondermake.bld_dir)'
  # If it's not empty, then it must end with a /
  $(if $(findstring / /,$(wondermake.bld_dir) /),, \
    $(wondermake.bld_dir) := $(wondermake.bld_dir)/ \
  )

  $(wondermake.bld_dir): ; mkdir -p $@
endif


###############################################################################
# Staged install

wondermake.staged_install := $(wondermake.bld_dir)staged-install/
$(wondermake.staged_install)bin/ $(wondermake.staged_install)lib/: ; mkdir -p $@

###############################################################################
endif # ifndef wondermake.init.included
