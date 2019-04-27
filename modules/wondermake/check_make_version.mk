# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

ifndef wondermake.check_make_version.included

###############################################################################
# Check make version

wondermake.min_required_make_version := 4.1.0
ifndef MAKE_RESTARTS # only do this on the first make phase
  ifeq '' '$(filter-out 0 1 2 3,$(word 1,$(subst ., ,$(MAKE_VERSION))))'
    $(error make version too old. have $(MAKE_VERSION). wants $(wondermake.min_required_make_version))
  endif
  ifeq '4' '$(word 1,$(subst ., ,$(MAKE_VERSION)))'
    ifeq '' '$(filter-out 0,$(word 2,$(subst ., ,$(MAKE_VERSION))))'
      $(error make version too old. have $(MAKE_VERSION). wants $(wondermake.min_required_make_version))
    endif
    ifeq '1' '$(word 2,$(subst ., ,$(MAKE_VERSION)))'
      #ifeq '' '$(filter-out 2,$(word 3,$(subst ., ,$(MAKE_VERSION))))'
      #  $(error make version too old. have $(MAKE_VERSION). wants $(wondermake.min_required_make_version))
      #endif
    endif
  endif
endif

###############################################################################
endif # ifndef wondermake.check_make_version.included
