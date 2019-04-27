# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

ifndef wondermake.init.included

.PHONY: wondermake.default wondermake.all
wondermake.all: wondermake.default

wondermake.dynamically_generated_makefiles := # this is an immediate var

###############################################################################
# Directory under which all derived files are put. It must end with a / or be empty.

ifndef wondermake.bld_dir
  ifneq '' '$(call wondermake.equals,$(realpath $(dir $(firstword $(MAKEFILE_LIST)))),$(realpath $(CURDIR)))'
    wondermake.bld_dir := ++build/
  endif
endif

ifneq '' '$(wondermake.bld_dir)'
  $(wondermake.bld_dir): ; mkdir -p $(@D)
endif

###############################################################################
# Staged install

$(wondermake.bld_dir)staged-install/bin/ $(wondermake.bld_dir)staged-install/lib/: ; mkdir -p $(@D)

###############################################################################
endif # ifndef wondermake.init.included
