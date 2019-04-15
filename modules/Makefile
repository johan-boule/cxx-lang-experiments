%.sig: %.val
	md5sum $< > $@.new
	if ! cmp $@.new $@; then mv $@.new $@; else rm $@.new; fi

.PHONY: force

scope.files = $(sort foo.o bar.o)
scope.files.old = $(file <scope.files)
scope.files.add = $(filter-out $(scope.files.old),$(scope.files))
scope.files.rm  = $(filter-out $(scope.files),$(scope.files.old))
scope.files: force
	$(if $(scope.files.rm),rm $(scope.files.rm))
	$(if $(scope.files.add) $(scope.files.rm),$(file >$@,$(scope.files)))

scope.cc = cc -flags
scope.cc.val: force
	echo $(scope.co) > $@

foo.o bar.o: %.o : %.c scope.cc.sig
	$(scope.co) -o $@ $<

scope.ld = ld -flags
foobar: scope.files
foobar: $(scope.files) 
	$(scope.ld) -o $@ $+
