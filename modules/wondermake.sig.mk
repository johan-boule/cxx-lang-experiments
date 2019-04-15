scope.src := $(sort $(wildcard *.c))
scope.src.old := $(file < scope.src)
scope.src.add := $(filter-out $(scope.src.old),$(scope.src))
scope.src.rm  := $(filter-out $(scope.src),$(scope.src.old))

$(info old $(scope.src.old))
$(info add $(scope.src.add))
$(info rm  $(scope.src.rm))

echo = printf '\033[33m$1\033[m\n'
echox = printf '\033[34m$1\033[m\n'

.PHONY: force

scope.cc = cp
scope.cc.val: force
	@$(call echo,$@: $+)
	@$(file >$@,$(scope.cc))

.PRECIOUS: %.sig
%.sig: %.val
	@$(call echo,$@: $+)
	@md5sum $< > $@.new
	@if ! cmp $@.new $@; \
	then \
	  mv $@.new $@; \
	  $(call echox,$@ changed); \
	else \
	  rm $@.new;\
	  $(call echox,$@ not changed); \
	fi

%.o: %.c scope.cc.sig
	@$(call echo,$@: $+)
	@$(scope.cc) $< $@

scope.src: force
	@$(call echo,$@: $+)
	@$(if $(scope.src.rm),rm $(scope.src.rm:c=o))
	$(call echox,$@ $(scope.src.add:%=+%) $(scope.src.rm:%=-%))
	@$(if $(scope.src.add)$(scope.src.rm),$(file >$@,$(scope.src)))

scope.ld = cat
foobar: scope.src
foobar: $(scope.src:c=o)
	@$(call echo,$@: $+)
	@$(scope.ld) $(filter-out scope.src,$+) > $@
