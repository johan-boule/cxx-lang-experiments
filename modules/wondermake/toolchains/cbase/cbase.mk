# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

ifndef wondermake.cbase.included
  wondermake.cbase.makefile_dir := $(dir $(lastword $(MAKEFILE_LIST)))
  include $(wondermake.cbase.makefile_dir)config/config.mk
  include $(wondermake.cbase.makefile_dir)template.mk
  include $(wondermake.cbase.makefile_dir)commands.mk
  include $(wondermake.cbase.makefile_dir)pkg-config.mk
  include $(wondermake.cbase.makefile_dir)compile_commands.json.mk
  undefine wondermake.cbase.makefile_dir
  define wondermake.cbase.main
    $(eval $(value wondermake.cbase.template.loop))
  endef
endif
