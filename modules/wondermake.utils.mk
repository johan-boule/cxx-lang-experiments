# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

###############################################################################
# This function checks whether the user has overriden a variable.
# $1 = the variable for which you want to test the origin
# returns the value of the variable if the user calling make has overridden it, or else the empty string
wondermake.user_override = $(if $(filter $(origin $1),undefined default),,$($1))

###############################################################################
# This function tests whether both arguments are equals
wondermake.equals = $(and $(findstring $1,$2),$(findstring $2,$1))

###############################################################################
# The newline character (useful in foreach statements)
define wondermake.newline


endef

###############################################################################
# Scope inheritance support functions

# Find the root scope of the inheritance hierarchy ($1 = scope)
wondermake.inherit_root = $(if $($1.inherit),$(call $0,$($1.inherit)),$1)

# Find the value of a variable by traversing the hierarchy ($1 = scope, $2 = var)
wondermake.inherit_unique = $(or $($1.$2),$(if $($1.inherit),$(call $0,$($1.inherit),$2)))

# Concatenate, by appending, the value of a list variable by traversing the hierarchy ($1 = scope, $2 = var)
wondermake.inherit_append = $($1.$2) $(if $($1.inherit),$(call $0,$($1.inherit),$2))

# Concatenate, by prepending, the value of a list variable by traversing the hierarchy ($1 = scope, $2 = var)
wondermake.inherit_prepend = $(if $($1.inherit),$(call $0,$($1.inherit),$2)) $($1.$2)

###############################################################################
# Rules that need to be always executed use this phony target as prerequisite
.PHONY: wondermake.force

###############################################################################
# Logging

ifneq '' '$(MAKE_TERMOUT)$(MAKE_TERMERR)'
  wondermake.term.0 := $(shell tput sgr0)
  wondermake.term := $(subst $(wondermake.term.0), , \
	$(shell \
		printf '%s\nsgr0\n' \
			'setaf 0' 'setaf 1' 'setaf 2' 'setaf 3' 'setaf 4' 'setaf 5' 'setaf 6' 'setaf 7' \
			bold dim \
		| tput -S \
	) \
  )
  wondermake.term.dark_grey  := $(word  1,$(wondermake.term))
  wondermake.term.red        := $(word  2,$(wondermake.term))
  wondermake.term.green      := $(word  3,$(wondermake.term))
  wondermake.term.yellow     := $(word  4,$(wondermake.term))
  wondermake.term.blue       := $(word  5,$(wondermake.term))
  wondermake.term.magenta    := $(word  6,$(wondermake.term))
  wondermake.term.cyan       := $(word  7,$(wondermake.term))
  wondermake.term.light_grey := $(word  8,$(wondermake.term))
  wondermake.term.bold       := $(word  9,$(wondermake.term))
  wondermake.term.dim        := $(word 10,$(wondermake.term))
  undefine wondermake.term
endif

ifdef MAKE_TERMOUT
  wondermake.maybe_colored_out = $1$2$3 # $1 = set color, $2 = message, $3 = reset color
else
  wondermake.maybe_colored_out = $2
endif

ifdef MAKE_TERMERR
  wondermake.maybe_colored_err = $1$2$3 # $1 = set color, $2 = message, $3 = reset color
else
  wondermake.maybe_colored_err = $2
endif

# If the wondermake.verbose var is set or make is not in silent mode
ifeq '' '$(if $(wondermake.verbose),,$(findstring s, $(firstword x$(MAKEFLAGS))))'
  wondermake.trace_style = $(call wondermake.maybe_colored_out,$(wondermake.term.cyan)$(wondermake.term.dim),$1,$(wondermake.term.0))
  wondermake.trace       = $(info         $(call wondermake.trace_style,$1))
  wondermake.trace_shell = printf '%s\n' '$(call wondermake.trace_style,$1)'
  
  wondermake.info_style  = $(call wondermake.maybe_colored_out,$(wondermake.term.cyan),$1,$(wondermake.term.0))
  wondermake.info        = $(info         $(call wondermake.info_style,$1))
  wondermake.info_shell  = printf '%s\n' '$(call wondermake.info_style,$1)'
else # Be quiet
  wondermake.trace :=
  wondermake.trace_shell := :

  wondermake.info :=
  wondermake.info_shell := :
endif

wondermake.warning_style = $(call wondermake.maybe_colored_err,$(wondermake.term.bold)$(wondermake.term.yellow),$1,$(wondermake.term.0))
wondermake.warning       = $(info         $(call wondermake.warning_style,$1))
wondermake.warning_shell = printf '%s\n' '$(call wondermake.warning_style,$1)' 1>&2

wondermake.error_style   = $(call wondermake.maybe_colored_err,$(wondermake.term.bold)$(wondermake.term.red),$1,$(wondermake.term.0))
wondermake.error         = $(error        $(call wondermake.error_style,$1))
wondermake.error_shell   = printf '%s\n' '$(call wondermake.error_style,$1)' 1>&2; false
