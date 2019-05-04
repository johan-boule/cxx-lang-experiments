# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

ifndef wondermake.cbase.commands.included

###############################################################################
# Pkg-config support

# Command to call pkg-config
define wondermake.cbase.pkg_config_command # $1 = scope, $2 = cflags or libs
$(strip
  $(if $(call wondermake.inherit_append,$1,pkg_config), \
    $(shell $(or $(call wondermake.user_override,PKG_CONFIG),$(call wondermake.inherit_unique,$1,pkg_config_prog)) $2 \
      $(if $(call wondermake.equals,static_executable,$(call wondermake.inherit_unique,$1,type)),--static) \
      $(call wondermake.inherit_append,$1,pkg_config_flags) \
      $(call wondermake.user_override,PKG_CONFIG_FLAGS) \
      '$(call wondermake.inherit_append,$1,pkg_config)' \
    ) \
  ) \
)
endef

###############################################################################
endif # ifndef wondermake.cbase.commands.included
