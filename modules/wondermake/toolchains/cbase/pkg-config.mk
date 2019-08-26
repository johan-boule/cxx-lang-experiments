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
    $(call wondermake.cbase.pkg_config_command_cached,$1,$(strip \
      $(or $(call wondermake.user_override,PKG_CONFIG),$(call wondermake.inherit_unique,$1,pkg_config_prog)) \
      $2 \
      $(if $(call wondermake.equals,static_executable,$(call wondermake.inherit_unique,$1,type)),--static) \
      $(call wondermake.inherit_append,$1,pkg_config_flags) \
      $(call wondermake.user_override,PKG_CONFIG_FLAGS) \
      '$(call wondermake.inherit_append,$1,pkg_config)' \
    )) \
  ) \
)
endef

define wondermake.cbase.pkg_config_command_cached # $1 = scope, $2 = args
  $(call wondermake.cbase.pkg_config_command_cached_recurse,$1,$2,x)
endef

define wondermake.cbase.pkg_config_command_cached_recurse # $1 = scope, $2 = args, $3 = index
  $(if $(wondermake.cbase.pkg_config_cache[$3].key), \
    $(if $(call wondermake.equals,$(wondermake.cbase.pkg_config_cache[$3].key),$2), \
      $(if $(wondermake.verbose),$(call wondermake.announce,$1,$2,result obtained from cache: $(wondermake.cbase.pkg_config_cache[$3].value))) \
      $(wondermake.cbase.pkg_config_cache[$3].value), \
      $(call $0,$1,$2,$3x))
  ,
    $(if $(wondermake.verbose),$(call wondermake.announce,pkg-config,$2)) \
    $(eval
      wondermake.cbase.pkg_config_cache[$3].key := $2
      wondermake.cbase.pkg_config_cache[$3].value := $(shell $2 || printf '%s ' '$$(call wondermake.error,'$2 'failed)')
    ) \
    $(if $(wondermake.verbose),$(call wondermake.print,$(wondermake.cbase.pkg_config_cache[$3].value))) \
    $(if $(wondermake.verbose),$(call wondermake.announce,$1,$2,put new result into cache: $(wondermake.cbase.pkg_config_cache[$3].value))) \
    $(wondermake.cbase.pkg_config_cache[$3].value) \
  )
endef

###############################################################################
endif # ifndef wondermake.cbase.commands.included
