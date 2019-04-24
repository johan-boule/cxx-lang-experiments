# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

include $(dir $(lastword $(MAKEFILE_LIST)))check_make_version.mk
include $(dir $(lastword $(MAKEFILE_LIST)))utils.mk
include $(dir $(lastword $(MAKEFILE_LIST)))log.mk
include $(dir $(lastword $(MAKEFILE_LIST)))init.mk
include $(dir $(lastword $(MAKEFILE_LIST)))clean.mk

###############################################################################
# Include only the toolchains used by the scopes
wondermake.toolchains := $(foreach scope,$(wondermake),$(call wondermake.inherit_unique,$(scope),toolchain))
ifneq '' '$(filter cbase,$(wondermake.toolchains))'
  include $(dir $(lastword $(MAKEFILE_LIST)))cbase/cbase.mk
endif

###############################################################################
 # Include the dynamically generated makefiles
 # GNU make will first build (if need be) all of these makefiles
 # before restarting itself to build the actual goal.
 #
 # In the case of implicit dependency files (.d files),
 # this will in turn trigger the building of the .ii files, on which the .d files depend.
 # So, preprocessing occurs on the first make phase.
 # Secondary expansion is used to allow variables to be defined out of order.
 # (Without secondary expansion, we have to include $(srcm).d before $(src).d)
ifeq '' '$(or $(call wondermake.equals,clean,$(MAKECMDGOALS)),$(call wondermake.equals,wondermake.clean,$(MAKECMDGOALS)))' # don't remake the .d files when cleaning
  .SECONDEXPANSION:
  -include $(wondermake.dynamically_generated_makefiles)
endif
###############################################################################
