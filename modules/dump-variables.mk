wondermake.find_element = $(if $(findstring <$1>,$(patsubst %,<%>,$2)),$1)
wondermake.escape := $(shell echo -en '\e')

MAKEFLAGS += --no-builtin-rules #--no-builtin-variables

# Beware that setting --no-builtin-variables via MAKEFLAGS in the makefile has no effect.
$(foreach v,$(sort $(.VARIABLES)), \
	$(if $(call wondermake.find_element,.VARIABLES,$(v)) \
		,,$(if $(call wondermake.find_element,default,$(origin $(v))) \
			,$(info $(wondermake.escape)[1;31m$(v) \
				$(wondermake.escape)[0;2m= $(value $(v)) \
				$(wondermake.escape)[0m) \
				$(eval undefine $(v)))))

$(foreach v,$(sort $(.VARIABLES)), \
	$(if $(call wondermake.find_element,environment,$(origin $(v))) \
		,,$(info $(wondermake.escape)[1;32m$(v) \
			$(wondermake.escape)[0;1;3m($(origin $(v)), $(flavor $(v))) \
			$(wondermake.escape)[0;2m= $(value $(v)) \
			$(wondermake.escape)[0m)))
