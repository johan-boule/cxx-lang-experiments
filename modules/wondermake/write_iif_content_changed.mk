# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

ifndef wondermake.write_iif_content_changed.included

###############################################################################
# Write a given scope variable to a file only when the var value differs from the content of the existing file,
# thereby preserving file timestamp if value has not changed. The file can then be used as a rule prerequisite.

define wondermake.write_iif_content_changed # $1 = scope, $2 = var, $3 = expression to evaluate
  $(wondermake.bld_dir)scopes/$1/$2: wondermake.force | $(wondermake.bld_dir)scopes/$1/
	$$(call wondermake.write_iif_content_changed.recipe,$1,$2,$3)
  wondermake.clean += $(wondermake.bld_dir)scopes/$1/$2
endef

# new way S(file < S@)
define wondermake.write_iif_content_changed.recipe # $1 = scope, $2 = var, $3 = expression to evaluate
	$(eval $1.$2 := $(subst $$,$$$$,$3))
	$(eval $1.$2.old := $(subst $$,$$$$,$(shell cat $@ 2>/dev/null)))
	$(if $(call wondermake.equals,$($1.$2),$($1.$2.old)), \
		$(if $(wondermake.verbose),$(call wondermake.announce,$1,compare $2,no change)) \
	, \
		$(call wondermake.announce,$1,compare $2) \
		$(call wondermake.notice,- $(filter-out $($1.$2),$($1.$2.old))$(wondermake.newline)+ $(filter-out $($1.$2.old),$($1.$2))) \
		$(file > $@,$($1.$2)) \
	)
	$(eval undefine $1.$2.old)
endef

###############################################################################
endif # ifndef wondermake.write_iif_content_changed.included
