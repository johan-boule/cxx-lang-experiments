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
# Query the value of a variable from the make command line: make wondermake.print:some-var
# It's equivalent to: echo '$(info $(some-var))' | make -f makefile -f -
# Note that make's --eval option seems to be processed before any -f option, so that's not an alternative.

wondermake.print\:%: ; @echo $* = $($*)

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
# Write a given content to a file only when that content differs from that of the existing file,
# thereby preserving timestamp if content has not changed.

define wondermake.write_iif_content_changed # $1 = scope, $2 = target, $3 = content, $4 = sort
  $2: wondermake.force
	$$(call wondermake.write_iif_content_changed.recipe,$1,$2,$3,$4)
  wondermake.clean += $2
endef

define wondermake.write_iif_content_changed.recipe # $1 = scope, $2 = target, $3 = content, $4 = sort
	$(eval $2.old := $(file < $2))
	$(eval $2.new := $(if $4,$(call $4,$3),$3))
	$(if $(call wondermake.equals,$($2.new),$($2.old)), \
		$(call wondermake.announce,$1,comparing $2,no change) \
	, \
		$(call wondermake.announce,$1,comparing $2) \
		$(call wondermake.notice,changed: \
			$(wondermake.newline)+ $(filter-out $($2.old),$($2.new)) \
			$(wondermake.newline)- $(filter-out $($2.new),$($2.old)) \
		) \
		$(file > $2,$($2.new)) \
	)
	$(eval undefine $2.old)
	$(eval undefine $2.new)
endef

###############################################################################
# Logging

ifneq '' '$(MAKE_TERMOUT)$(MAKE_TERMERR)'
  wondermake.term.0 := $(shell tput sgr0)
  wondermake.term := $(subst $(wondermake.term.0), , \
	$(shell \
		printf '%s\nsgr0\n' \
			'setaf 0' 'setaf 1' 'setaf 2' 'setaf 3' 'setaf 4' 'setaf 5' 'setaf 6' 'setaf 7' \
			bold dim \
		| tput -S; \
		printf '\033[21m \033[22m' \
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
  wondermake.term.bold_off   := $(word 11,$(wondermake.term))
  wondermake.term.dim_off    := $(word 12,$(wondermake.term))
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
  wondermake.trace_style  := $(wondermake.term.cyan)$(wondermake.term.dim)
  wondermake.trace         = $(info        $(call wondermake.maybe_colored_out,$(wondermake.trace_style),$1,$(wondermake.term.0)))
  wondermake.trace_shell   = printf '%s\n' $(call wondermake.maybe_colored_out,'$(wondermake.trace_style)',"$1",'$(wondermake.term.0)')
  
  wondermake.info_style   := $(wondermake.term.cyan)
  wondermake.info          = $(info        $(call wondermake.maybe_colored_out,$(wondermake.info_style),$1,$(wondermake.term.0)))
  wondermake.info_shell    = printf '%s\n' $(call wondermake.maybe_colored_out,'$(wondermake.info_style)',"$1",'$(wondermake.term.0)')

  wondermake.notice_style := $(wondermake.term.magenta)$(wondermake.term.bold)
  wondermake.notice        = $(info        $(call wondermake.maybe_colored_out,$(wondermake.notice_style),$1,$(wondermake.term.0)))
  wondermake.notice_shell  = printf '%s\n' $(call wondermake.maybe_colored_out,'$(wondermake.notice_style)',"$1",'$(wondermake.term.0)')
else # Be quiet
  wondermake.trace :=
  wondermake.trace_shell := :

  wondermake.info :=
  wondermake.info_shell := :

  wondermake.notice :=
  wondermake.notice_shell := :
endif

wondermake.warning_style := $(wondermake.term.bold)$(wondermake.term.yellow)
wondermake.warning        = $(warning     $(call wondermake.maybe_colored_out,$(wondermake.warning_style),$1,$(wondermake.term.0)))
wondermake.warning_shell  = printf '%s\n' $(call wondermake.maybe_colored_out,'$(wondermake.warning_style)',"$1",'$(wondermake.term.0)') 1>&2

wondermake.error_style   := $(wondermake.term.bold)$(wondermake.term.red)
wondermake.error          = $(error       $(call wondermake.maybe_colored_out,$(wondermake.error_style),$1,$(wondermake.term.0)))
wondermake.error_shell    = printf '%s\n' $(call wondermake.maybe_colored_out,'$(wondermake.error_style)',"$1",'$(wondermake.term.0)') 1>&2; false

wondermake.announce = \
  $(eval wondermake.progress += x) \
  $(call wondermake.info \
		,$(strip $(call wondermake.maybe_colored_out,$(wondermake.term.bold),[$(or $(MAKE_RESTARTS),0):$(words $(wondermake.progress))] {$1},$(wondermake.term.bold_off))) \
		$(strip $2) \
		$(strip $(call wondermake.maybe_colored_out,$(wondermake.term.dim),$3,$(wondermake.term.dim_off))))

ifdef MAKE_RESTARTS
  $(call wondermake.announce,make restarts)
endif
