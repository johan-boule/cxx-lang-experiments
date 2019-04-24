# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

.PHONY: wondermake.default wondermake.all
wondermake.all: wondermake.default

wondermake.dynamically_generated_makefiles := # this is an immediate var

###############################################################################
# Directory under which all derived files are put. must end with a / or be empty.

ifndef wondermake.bld_dir
  ifneq '' '$(call wondermake.equals,$(realpath $(dir $(firstword $(MAKEFILE_LIST)))),$(realpath $(CURDIR)))'
    wondermake.bld_dir := ++build/
  endif
endif

$(wondermake.bld_dir): ; mkdir -p $@
