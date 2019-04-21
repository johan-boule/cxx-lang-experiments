# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

###############################################################################
# All rules producing a derived file appends it to this variable
wondermake.clean := # this is an immediate var

###############################################################################
# Clean rule

.PHONY: wondermake.clean
wondermake.clean:
	$(call wondermake.info,clean)
	printf '%s' '$(wondermake.clean)' | xargs rm -f; \
	printf '%s' '$(sort $(dir $(wondermake.clean)))' | xargs rmdir -p 2>/dev/null || true

###############################################################################
# Auto-clean rule

wondermake.default: wondermake.auto-clean
wondermake.auto-clean: wondermake.force
	$(call wondermake.info,auto-clean)
	$(eval $@.old := $(file < $@))
	$(eval $@.new := $(sort $(wondermake.clean)))
	$(if $(call wondermake.equals,$($@.old),$($@.new)), \
		$(call wondermake.trace,no change) \
	, \
		$(eval $@.rm := $(filter-out $($@.new),$($@.old))) \
		$(if $($@.rm), \
			$(call wondermake.info,$(call wondermake.maybe_colored_out,$(wondermake.term.green),removing $($@.rm))) \
			printf '%s' '$($@.rm)' | xargs rm -f ; \
			printf '%s' '$(sort $(dir $($@.rm)))' | xargs rmdir -p 2>/dev/null || true; \
			printf '%s\n' '$($@.new)' > $@ \
		, \
			$(call wondermake.trace,nothing to remove) \
			$(file > $@,$($@.new)) \
		) \
		$(eval undefine $@.rm) \
	)
	$(eval undefine $@.old)
	$(eval undefine $@.new)
wondermake.clean += wondermake.auto-clean
