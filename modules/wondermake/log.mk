# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

ifndef wondermake.log_included

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

ifdef MAKE_TERMOUT # $1 = set color, $2 = message
  wondermake.maybe_colored_out       = $1$2$(wondermake.term.0)
  wondermake.maybe_colored_out_shell = '$1'"$2"'$(wondermake.term.0)'
else
  wondermake.maybe_colored_out       = $2
  wondermake.maybe_colored_out_shell = "$2"
endif

ifdef MAKE_TERMERR # $1 = set color, $2 = message
  wondermake.maybe_colored_err       = $1$2$(wondermake.term.0)
  wondermake.maybe_colored_err_shell = '$1'"$2"'$(wondermake.term.0)'
else
  wondermake.maybe_colored_err       = $2
  wondermake.maybe_colored_err_shell = "$2"
endif

# If the wondermake.verbose var is set or make is not in silent mode
ifeq '' '$(if $(wondermake.verbose),,$(findstring s, $(firstword x$(MAKEFLAGS))))'
  wondermake.print         = $(info $1)
  wondermake.print_shell   = printf '%s\n' $1

  wondermake.trace_style  := $(wondermake.term.cyan)$(wondermake.term.dim)
  wondermake.trace         = $(info        $(call wondermake.maybe_colored_out,$(wondermake.trace_style),$1))
  wondermake.trace_shell   = printf '%s\n' $(call wondermake.maybe_colored_out_shell,$(wondermake.trace_style),$1)
  
  wondermake.info_style   := $(wondermake.term.cyan)
  wondermake.info          = $(info        $(call wondermake.maybe_colored_out,$(wondermake.info_style),$1))
  wondermake.info_shell    = printf '%s\n' $(call wondermake.maybe_colored_out_shell,$(wondermake.info_style),$1)

  wondermake.notice_style := $(wondermake.term.yellow)$(wondermake.term.bold)
  wondermake.notice        = $(info        $(call wondermake.maybe_colored_out,$(wondermake.notice_style),$1))
  wondermake.notice_shell  = printf '%s\n' $(call wondermake.maybe_colored_out_shell,$(wondermake.notice_style),$1)

  wondermake.announce_style := $(wondermake.term.blue)$(wondermake.term.bold)
  wondermake.announce = \
    $(if $(MAKE_TERMOUT),,$(info ===============================================================================)) \
    $(if $4, \
      $(info \
        $(call wondermake.maybe_colored_out,$(wondermake.announce_style)$(wondermake.term.bold),{$1}) \
        $(call wondermake.maybe_colored_out,$(wondermake.info_style)$(wondermake.term.bold),$2) \
        $(call wondermake.maybe_colored_out,$(wondermake.info_style),$3) \
        $(call wondermake.maybe_colored_out,$(wondermake.info_style)$(wondermake.term.dim),$4) \
      ), \
      $(info \
        $(call wondermake.maybe_colored_out,$(wondermake.announce_style)$(wondermake.term.bold),{$1}) \
        $(call wondermake.maybe_colored_out,$(wondermake.info_style),$2) \
        $(call wondermake.maybe_colored_out,$(wondermake.info_style)$(wondermake.term.dim),$3) \
      ) \
    )
  wondermake.announce_shell = \
    $(if $(MAKE_TERMOUT),,printf '===============================================================================\n';) \
    $(if $4, \
      printf  '%s'   $(call wondermake.maybe_colored_out_shell,$(wondermake.announce_style),{$1}); \
      printf ' %s'   $(call wondermake.maybe_colored_out_shell,$(wondermake.info_style)$(wondermake.term.bold),$2); \
      printf ' %s'   $(call wondermake.maybe_colored_out_shell,$(wondermake.info_style),$3); \
      printf ' %s\n' $(call wondermake.maybe_colored_out_shell,$(wondermake.info_style)$(wondermake.term.dim),$4) \
    , \
      printf  '%s'   $(call wondermake.maybe_colored_out_shell,$(wondermake.announce_style),{$1}); \
      printf ' %s'   $(call wondermake.maybe_colored_out_shell,$(wondermake.info_style),$2); \
      printf ' %s\n' $(call wondermake.maybe_colored_out_shell,$(wondermake.info_style)$(wondermake.term.dim),$3) \
    )

else # Be quiet. We need a no-op definition for the shell, because these calls may be followed by a semicolon and it's syntax error to have a stray semicolon.
  wondermake.print_shell := :
  wondermake.trace_shell := :
  wondermake.info_shell := :
  wondermake.notice_shell := :
  wondermake.announce_shell := :
endif

wondermake.warning_style := $(wondermake.term.bold)$(wondermake.term.magenta)
wondermake.warning        = $(warning     $(call wondermake.maybe_colored_err,$(wondermake.warning_style),warning: $1))
wondermake.warning_shell  = printf '%s\n' $(call wondermake.maybe_colored_err_shell,$(wondermake.warning_style),warning: $1) 1>&2

wondermake.error_style   := $(wondermake.term.bold)$(wondermake.term.red)
wondermake.error          = $(error       $(call wondermake.maybe_colored_err,$(wondermake.error_style),error: $1))
wondermake.error_shell    = printf '%s\n' $(call wondermake.maybe_colored_err_shell,$(wondermake.error_style),error: $1) 1>&2; false

###############################################################################

ifdef MAKE_RESTARTS
  $(call wondermake.announce,make restarts,$(MAKE_RESTARTS))
endif

###############################################################################
endif # ifndef wondermake.log_included
