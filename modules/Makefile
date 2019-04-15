%.sig: %.val
        md5sum $< > $@.new
        if ! cmp $@.new $@; then mv $@.new $@; else rm $@.new; fi

scope.files = $(sort foo.o bar.o)
scope.files.old = $(file <scope.files)
scope.files.add = $(filter-out $(scope.files.old),$(scope.files))
scope.files.rm  = $(filter-out $(scope.files),$(scope.files.old))
scope.files: force
	$(if $(scope.files.rm),rm $(scope.files.rm))
	$(if $(scope.files.add) $(scope.files.rm),$(file >$@,$(scope.files)))

.PHONY: force
scope.cc = touch
scope.cc.val: force
	$(file >$0,$(scope.cc))

foo.o bar.o: %.o : %.c scope.cc.sig
	$(scope.co) -o $@ $<

scope.ld = touch
foobar: scope.files
foobar: $(scope.files)
	$(scope.ld) -o $@ $+
