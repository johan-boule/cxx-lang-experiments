# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

ifndef wondermake.fhs.included

###############################################################################
# Filesystem hierarchy standard

wondermake.fhs.bin := $(wondermake.staged_install)bin/
wondermake.fhs.lib := $(wondermake.staged_install)lib/
wondermake.fhs.include := $(wondermake.staged_install)include/
wondermake.fhs.bin_to_lib := ../lib

$(wondermake.fhs.bin) $(wondermake.fhs.lib): ; mkdir -p $@

###############################################################################
endif # ifndef wondermake.fhs.included
