#! /usr/bin/make -f

MAKEFLAGS += --no-builtin-rules --no-builtin-variables

.PHONY: all clean debug

# the directory where the makefile is
src_dir := $(dir $(lastword $(MAKEFILE_LIST)))

bin := main
src_path := src
module_path := $(src_path)
include_path := $(src_path)

srcm := $(shell find $(patsubst %,$(src_dir)%/,$(module_path)) -name '*.cppm')
src  := $(shell find $(patsubst %,$(src_dir)%/,$(src_path))    -name '*.cpp' )

vpath %.cppm $(src_dir)
vpath %.cpp  $(src_dir)

ifneq '' '$(findstring $(origin CXX), undefined default)'
  CXX := clang++
endif

CPP := $(CXX) -E
LD := $(CXX)

ifndef GNU_SED
  GNU_SED := $(shell command -v gsed || command -v sed)
endif

mkdir_target = mkdir -p $(dir $@)
link       = $(LD)  -o $@ $(LDFLAGS) $^ $(LDLIBS)
compile    = $(CXX) -o $@ -std=c++2a -fmodules-ts $(patsubst %,-fprebuilt-module-path=%,$(module_path)) $(CXXFLAGS)
preprocess = $(CPP) -o $@ $(patsubst %,-I$(src_dir)%,$(include_path)) -MT $@ -MF $@.d -MMD -MP $(CPPFLAGS) $<

define parse_export_module_keyword
  $(call echo,parse export module keyword $< >> $@)
  $(GNU_SED) -rn 's,^[ 	]*export[ 	]+module[ 	]+([^[ 	;]+)[ 	;],module_map[\1] := $*.pcm,p' $< >> $@
endef

define parse_module_keyword
  $(call echo,parse module keyword $< >> $@)
  $(GNU_SED) -rn 's,^[ 	]*module[ 	]+([^[ 	;]+)[ 	;],$*.o: private belong_to_module := $$(module_map[\1])\n$*.o: $$(module_map[\1]),p' $< >> $@
endef

define parse_import_keyword # $(1) = dependency target
  $(call echo,parse import keyword $< >> $@)
  $(GNU_SED) -rn 's,^[ 	]*import[ 	]+([^[ 	;]+)[ 	;],$(1): $$(module_map[\1]),p' $< >> $@
endef

bmi := $(patsubst $(src_dir)%.cppm,%.pcm,$(srcm))
obj := $(patsubst $(src_dir)%.cpp,%.o,$(src))
ii  := $(patsubst $(src_dir)%,%.ii,$(srcm) $(src))
dep := $(patsubst %.ii,%.ii.d,$(ii))

all: $(bin)

$(bin): $(obj)
	$(call echo,link $@ from objects $^)
	$(link)

%.o: %.cpp.ii
	$(call echo,compile $< to $@)
	@$(mkdir_target)
	$(compile) -fmodule-file=$(belong_to_module) -c $<

%.pcm: %.cppm.ii
	$(call echo,precompile module interface $< to $@)
	@$(mkdir_target)
	$(compile) --precompile -x c++-module $<

%.cppm.ii.d: %.cppm.ii
	$(parse_export_module_keyword)
	$(call parse_import_keyword,$*.pcm)

%.cpp.ii.d: %.cpp.ii
	$(parse_module_keyword)
	$(call parse_import_keyword,$*.o)

%.ii: %
	$(call echo,preprocess $< to $@)
	@$(mkdir_target)
	$(preprocess)

.PRECIOUS: $(ii) $(bmi)

ifneq '$(MAKECMDGOALS)' 'clean'
  include $(dep)
endif

# check whether make is in silent mode
ifeq '' '$(findstring s, $(firstword x$(MAKEFLAGS)))'
  echo = @echo $${MAKE_TERMOUT:+'\033[1;36m'}'$(1)'$${MAKE_TERMOUT:+'\033[0m'}
else
  echo := @:
endif

clean:
	rm -f $(bin) $(obj) $(bmi) $(ii) $(dep)

debug:
	@echo CPP $(origin CPP) $(CPP)
	@echo CXX $(origin CXX) $(CXX)
	@echo LD $(origin LD) $(LD)
	@echo GNU_SED $(origin GNU_SED) $(GNU_SED)
	@echo src_dir $(src_dir)
	@echo srcm $(srcm)
	@echo src $(src)
	@echo bmi $(bmi)
	@echo obj $(obj)
	@echo ii $(ii)
	@echo dep $(dep)
	@for dep in $(dep); \
	do \
		echo; \
		echo ================ $$dep ================; \
		if test -f $$dep; then cat $$dep; else echo no file; fi; \
		echo; \
	done
