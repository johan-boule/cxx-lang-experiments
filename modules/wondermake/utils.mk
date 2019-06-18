# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

ifndef wondermake.utils.included

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
# The comma character (useful in function calls when you want to pass a literal comma)
wondermake.comma := ,

###############################################################################
# Query the value of a variable from the make command line: make wondermake.print:some-var
# It's equivalent to: echo '$(info $(some-var))' | make -f makefile -f -
# Note that make's --eval option seems to be processed before any -f option, so that's not an alternative.
wondermake.print\:%:
	$(eval wondermake.print := $($*))
	$(info $* = $(value wondermake.print))
	$(eval undefine wondermake.print)

wondermake.print-pattern\:%:
	$(foreach v,$(sort $(.VARIABLES)), \
		$(if $(patsubst $*,,$v),, \
			$(info $v = $(value $v)) \
		) \
	)

###############################################################################
# Rules that need to be always executed use this phony target as prerequisite
.PHONY: wondermake.force

###############################################################################
# Scope inheritance support functions

# Find the value of a variable by traversing the hierarchy ($1 = scope, $2 = var)
wondermake.inherit_unique = $(or $($1.$2),$(if $($1.inherit),$(call $0,$($1.inherit),$2)))

# Concatenate, by appending, the value of a list variable by traversing the hierarchy ($1 = scope, $2 = var)
wondermake.inherit_append = $(strip $($1.$2) $(if $($1.inherit),$(call $0,$($1.inherit),$2)))

# Concatenate, by prepending, the value of a list variable by traversing the hierarchy ($1 = scope, $2 = var)
wondermake.inherit_prepend = $(strip $(if $($1.inherit),$(call $0,$($1.inherit),$2)) $($1.$2))

###############################################################################
# Add a default inheritance on the wondermake.<toolchain> scope for each user-declared scope

# Find the root scope of the inheritance hierarchy ($1 = scope)
wondermake.__inherit_root__ = $(if $($1.inherit),$(call $0,$($1.inherit)),$1)

$(foreach s,$(wondermake), \
	$(if $(filter wondermake.$(call wondermake.inherit_unique,$s,toolchain),$(call wondermake.__inherit_root__,$s)) \
		,,$(eval $(call wondermake.__inherit_root__,$s).inherit := wondermake.$(call wondermake.inherit_unique,$s,toolchain))))
		# Note: the same root may be visited multiple times so we must take care of not making the wondermake.<toolchain> scope inherit from itself.

undefine wondermake.__inherit_root__

###############################################################################
# Depencency support functions

define wondermake.topologically_sorted_unique_deep_deps # $1 = scope, $2 = expose_private_deep_deps
$(strip
  $(eval $1.topologically_sorted_unique_deep_deps :=)
  $(call wondermake.topologically_sorted_unique_deep_deps.__recurse__,$1,$2,$1.topologically_sorted_unique_deep_deps,x)
  $($1.topologically_sorted_unique_deep_deps)
  $(eval undefine $1.topologically_sorted_unique_deep_deps)
)
endef

define wondermake.topologically_sorted_unique_deep_deps.__recurse__ # $1 = scope, $2 = expose_private_deep_deps, $3 = accumulator, $4 = is_root
  $(foreach d,$(call wondermake.inherit_append,$1,public_deps) $(if $(or $4,$2),$(call wondermake.inherit_append,$1,private_deps)),
    $(eval $3 := $(filter-out $d,$($3)) $d)
    $(call $0,$d,$2,$3)
  )
endef

###############################################################################
endif # ifndef wondermake.utils.included
