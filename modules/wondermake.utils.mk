# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

###############################################################################
# Miscellaneous utility functions

# This function finds a word in a list
# $1 = the word to find
# $2 = the list in which to search the word for
# returns the word if found, or else the empty string
wondermake.find_word = $(if $(findstring <$1>,$(patsubst %,<%>,$2)),$1)

# This function checks whether the user has overriden a variable.
# $1 = the variable for which you want to test the origin
# returns the value of the variable if the user calling make has overridden it, or else the empty string
wondermake.user_override = $(if $(call wondermake.find_word,$(origin $1),undefined default),,$($1))

# The newline character (useful in foreach statements)
define wondermake.newline


endef

###############################################################################
# Logging

# check whether the verbose var is set or make is not silent mode
ifeq '' '$(if $(wondermake.verbose),,$(findstring s, $(firstword x$(MAKEFLAGS))))'
  # if so, emit messages (both make phases have their own color)
  wondermake.echo = echo -e $${MAKE_TERMOUT:+'\033[$(if $(MAKE_RESTARTS),33,36)m'}$1$${MAKE_TERMOUT:+'\033[m'}
else
  # else, be quiet
  wondermake.echo := :
endif

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
