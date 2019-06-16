# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

ifndef wondermake.compile_commands.included

###############################################################################
# Compilation database (a pretentious name given to the dumb file compile_commands.json)

wondermake.default: $(wondermake.bld_dir)compile_commands.json

wondermake.cbase.compile_commands := # this is an immediate var
wondermake.cbase.compile_commands.json := # this is an immediate var

.SECONDEXPANSION:
$(wondermake.bld_dir)compile_commands.json: $$(wondermake.cbase.compile_commands) | $$(wondermake.cbase.compile_commands.json)
	$(call wondermake.announce,$(@F),$@)
	@printf '[\n' > $@; \
	$(if $|,printf '%s ' $| | xargs cat | head -q -c-2 >> $@;) \
	printf '\n]\n' >> $@
# $(file > $@,[$(wondermake.newline)$(foreach j,$|,$(file < $j))]$(wondermake.newline))
wondermake.clean += $(wondermake.bld_dir)compile_commands.json

###############################################################################
endif # ifndef wondermake.compile_commands.included
