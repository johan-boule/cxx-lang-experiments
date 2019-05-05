# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

ifndef wondermake.write_iif_content_changed.included

###############################################################################
# Write a given scope variable to a file only when the var value differs from the content of the existing file,
# thereby preserving file timestamp if value has not changed. The file can then be used as a rule prerequisite.

define wondermake.write_iif_content_changed # $1 = scope, $2 = var, $3 = value
  $(wondermake.scopes_dir)$1/$2: wondermake.force | $(wondermake.scopes_dir)$1/
	$$(call wondermake.write_iif_content_changed.recipe,$1,$2,$3)
  wondermake.clean += $(wondermake.scopes_dir)$1/$2
endef

# new way S(file < S@)
define wondermake.write_iif_content_changed.recipe # $1 = scope, $2 = var, $3 = value
	$(eval
		$1.$2 := $(subst $$,$$$$,$3)
		$1.$2.old := $(subst $$,$$$$,$(shell cat $@ 2>/dev/null))
	)
	$(if $(call wondermake.equals,$($1.$2),$($1.$2.old)), \
		$(if $(wondermake.verbose),$(call wondermake.announce,$1,compare $2,no change)) \
	, \
		$(call wondermake.announce,$1,compare $2) \
		@set -e && \
		if test -e $@; \
		then \
			$(call wondermake.notice_shell,"'changed:- $(filter-out $($1.$2),$($1.$2.old))'"); \
			$(call wondermake.notice_shell,"'changed:+ $(filter-out $($1.$2.old),$($1.$2))'"); \
			$(call wondermake.if_not_silent_shell,printf '%s\n' '$($1.$2)' $(wondermake.diff)); \
		else \
			$(call wondermake.if_not_silent_shell,printf '%s\n' '$($1.$2)'); \
		fi; \
		printf '%s\n' '$($1.$2)' > $@ \
	)
	$(eval undefine $1.$2.old)
endef

###############################################################################
# Write the result of a given shell expression to a file only when the result differs from the content of the existing file,
# thereby preserving file timestamp if result has not changed. The file can then be used as a rule prerequisite.

define wondermake.write_iif_content_changed_shell # $1 = announce, # $2 = file, $3 = value
  $(wondermake.bld_dir)$2: wondermake.force | $(dir $(wondermake.bld_dir)$2)
	$$(call wondermake.write_iif_content_changed_shell.recipe,$1,$2,$3)
  wondermake.clean += $(wondermake.bld_dir)$2
endef

define wondermake.write_iif_content_changed_shell.recipe # $1 = announce, # $2 = file, $3 = value
	@set -e && \
	new=$$($3); \
	if test "$$new" = "$$(cat $@ 2>/dev/null)"; \
	then \
		$(if $(wondermake.verbose),$(call wondermake.announce_shell,$1,compare $@,no change),:); \
	else \
		$(call wondermake.announce_shell,$1,compare $@); \
		if test -e $@; \
		then \
			$(call wondermake.notice_shell,changed:); \
			$(call wondermake.if_not_silent_shell,printf '%s\n' "$$new" $(wondermake.diff)); \
		else \
			$(call wondermake.if_not_silent_shell,printf '%s\n' "$$new"); \
		fi; \
		printf '%s\n' "$$new" > $@; \
	fi
endef

$(eval $(call wondermake.write_iif_content_changed_shell,test,date,date))
wondermake.default: $(wondermake.bld_dir)date

###############################################################################
# A shell pipe to show diff between $@ and standard input
wondermake.diff = | $$(command -v wdiff -n || diff -y -W$$(tput cols)) $@ -$(if $(MAKE_TERMOUT), | $$(command -v colordiff || cat))

###############################################################################
endif # ifndef wondermake.write_iif_content_changed.included
