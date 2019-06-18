# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

ifndef wondermake.fhs.included

###############################################################################
# Filesystem hierarchy standard

wondermake.fhs := $(wondermake.bld_dir)wondermake.staged-install/
wondermake.fhs.bin := $(wondermake.fhs)bin/
wondermake.fhs.lib := $(wondermake.fhs)lib/
wondermake.fhs.include := $(wondermake.fhs)include/
wondermake.fhs.bin_to_lib := ../lib

$(wondermake.fhs.bin) $(wondermake.fhs.lib) $(wondermake.fhs.include): ; mkdir -p $@

###############################################################################
endif # ifndef wondermake.fhs.included
