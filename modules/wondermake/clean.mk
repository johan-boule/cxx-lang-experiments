# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

ifndef wondermake.clean.included

###############################################################################
# All derived files are appended it to this variable

wondermake.clean := # this is an immediate var

###############################################################################
# Clean rule

.PHONY: wondermake.clean
wondermake.clean:
	$(call wondermake.announce,clean)
	printf '%s' '$(wondermake.clean)' | xargs rm -f; \
	printf '%s' '$(sort $(dir $(wondermake.clean)))' | xargs rmdir -p 2>/dev/null || true

###############################################################################
# Auto-clean rule

wondermake.default: $(wondermake.bld_dir)wondermake.auto-clean
$(wondermake.bld_dir)wondermake.auto-clean: wondermake.force | $(wondermake.bld_dir)
	$(eval $@.old := $(subst $$,$$$$,$(shell cat $@ 2>/dev/null)))
	$(eval $@.new := $(sort $(wondermake.clean)))
	$(if $(call wondermake.equals,$($@.old),$($@.new)), \
		$(if $(wondermake.verbose),$(call wondermake.announce,auto-clean,,no change)) \
	, \
		$(eval $@.rm := $(filter-out $($@.new),$($@.old))) \
		$(if $($@.rm), \
			$(call wondermake.announce,auto-clean) \
			$(call wondermake.notice,removing $($@.rm)) \
			@printf '%s' '$($@.rm)' | xargs rm -f; \
			printf '%s' '$(sort $(dir $($@.rm)))' | xargs rmdir -p 2>/dev/null || true; \
			printf '%s\n' '$($@.new)' > $@.new; \
			mv $@.new $@ \
		, \
			$(call wondermake.announce,auto-clean,new files,nothing to remove) \
			$(file > $@.new,$($@.new)) \
			@mv $@.new $@ \
		) \
		$(eval undefine $@.rm) \
	)
	$(eval undefine $@.old)
	$(eval undefine $@.new)
wondermake.clean += \
	$(wondermake.bld_dir)wondermake.auto-clean \
	$(wondermake.bld_dir)wondermake.auto-clean.new

###############################################################################
endif # ifndef wondermake.clean.included
