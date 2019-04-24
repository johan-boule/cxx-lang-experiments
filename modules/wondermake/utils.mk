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
# Write a given scope variable to a file only when the var value differs from the content of the existing file,
# thereby preserving file timestamp if value has not changed.

define wondermake.write_iif_content_changed.rule # $1 = scope, $2 = var, $3 = expression to evaluate
  $(wondermake.bld_dir)$1.$2: wondermake.force | $(wondermake.bld_dir)
	$$(call wondermake.write_iif_content_changed.recipe,$1,$2,$3)
  wondermake.clean += $(wondermake.bld_dir)$1.$2
endef

define wondermake.write_iif_content_changed.recipe # $1 = scope, $2 = var, $3 = expression to evaluate
	$(eval $1.$2 := $(subst $$,$$$$,$3))
	$(eval $1.$2.old := $(subst $$,$$$$,$(shell cat $@)))
	$(if $(call wondermake.equals,$($1.$2),$($1.$2.old)), \
		$(call wondermake.announce,$1,comparing $2,no change) \
	, \
		$(call wondermake.announce,$1,comparing $2) \
		$(call wondermake.notice,changed: \
			$(wondermake.newline)- $(filter-out $($1.$2),$($1.$2.old)) \
			$(wondermake.newline)+ $(filter-out $($1.$2.old),$($1.$2)) \
		) \
		$(file > $@,$($1.$2)) \
	)
	$(eval undefine $1.$2.old)
endef
