# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

include $(dir $(lastword $(MAKEFILE_LIST)))src-suffixes.mk
include $(dir $(lastword $(MAKEFILE_LIST)))config.unix-elf-clang.mk
include $(dir $(lastword $(MAKEFILE_LIST)))config.mk
include $(dir $(lastword $(MAKEFILE_LIST)))template.mk
