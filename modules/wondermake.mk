# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

wondermake.clean := # this is an immediate var
include $(dir $(lastword $(MAKEFILE_LIST)))wondermake.utils.mk
include $(dir $(lastword $(MAKEFILE_LIST)))wondermake.config.mk
include $(dir $(lastword $(MAKEFILE_LIST)))wondermake.template.mk
