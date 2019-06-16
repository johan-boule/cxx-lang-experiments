# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

ifndef wondermake.included

wondermake.makefile_dir := $(dir $(lastword $(MAKEFILE_LIST)))
include $(wondermake.makefile_dir)check_make_version.mk
include $(wondermake.makefile_dir)utils.mk
include $(wondermake.makefile_dir)log.mk
include $(wondermake.makefile_dir)init.mk
include $(wondermake.makefile_dir)write_iif_content_changed.mk
include $(wondermake.makefile_dir)fhs.mk
include $(wondermake.makefile_dir)clean.mk

###############################################################################
# Define the main entry point as a function
# The function is reentrant and supports a modular toolchain inclusion.

define wondermake.main # Note that special care here is taken to allow this function to be called without the usual $(eval $(value V))
  $(eval
    # Loop through the toolchains used by the scopes
    $(foreach toolchain,$(sort $(foreach scope,$(wondermake),$(call wondermake.inherit_unique,$(scope),toolchain))),
      # Include the toolchain
      $(eval include $(wondermake.makefile_dir)/toolchains/$(toolchain)/$(toolchain).mk)
      # Forwards to the toolchain's main function
      $(eval $(value wondermake.$(toolchain).main))
    )
  )
endef

###############################################################################
endif # ifndef wondermake.included
