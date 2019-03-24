#! /usr/bin/make -f

MAKEFLAGS += --no-builtin-rules --no-builtin-variables

.PHONY: all clean debug

src_dir := $(dir $(lastword $(MAKEFILE_LIST)))

bin := main
include_path := src

srcm := $(shell find $(src_dir)$(include_path)/ -name '*.cppm')
src  := $(shell find $(src_dir)$(include_path)/ -name '*.cpp' )

vpath %.cppm $(src_dir)
vpath %.cpp  $(src_dir)

ifneq '' '$(findstring $(origin CXX), undefined default)'
  CXX := clang++
endif

CPP := $(CXX) -E
LD := $(CXX)

GNU_GREP ?= grep
GNU_SED ?= sed

mkdir_target = mkdir -p $(dir $@)
link = $(LD) -o $@ $(LDFLAGS) $^ $(LDLIBS)
compile = $(CXX) -o $@ -std=c++2a -fmodules-ts -fprebuilt-module-path=$(include_path) $(CXXFLAGS)
preprocess = $(CPP) -o $@ -I$(src_dir)$(include_path) -MT $@ -MF $@.d -MMD -MP $(CPPFLAGS) $<

define parse_export_module_keyword
  $(call echo,parse export module keyword $@ >> $@.d)
  $(GNU_GREP) -E '^[ 	]*export[ 	]+module[ 	]+[^[ 	;]+[ 	;]' $@ | \
  $(GNU_SED) -r -e 's,^[ 	]*export[ 	]+module[ 	]+([^[ 	;]+)[ 	;],\1_MODULE = $(include_path)/\1.pcm,' \
  >> $@.d
endef

define parse_module_keyword # $(1) = target
  $(call echo,parse module keyword $@ >> $@.d)
  $(GNU_GREP) -E '^[ 	]*module[ 	]+[^[ 	;]+[ 	;]' $@ | \
  $(GNU_SED) -r -e 's,^[ 	]*module[ 	]+([^[ 	;]+)[ 	;],$(1): $(include_path)/\1.pcm,' \
  >> $@.d
endef

define parse_import_keyword # $(1) = target
  $(call echo,parse imports keyword $@ >> $@.d)
  $(GNU_GREP) -E '^[ 	]*import[ 	]+[^[ 	;]+[ 	;]' $@ | \
  $(GNU_SED) -r -e 's,^[ 	]*import[ 	]+([^[ 	;]+)[ 	;],$(1): $(include_path)/\1.pcm,' \
  >> $@.d
endef

bmi := $(patsubst $(src_dir)%.cppm,%.pcm,$(srcm))
obj := $(patsubst $(src_dir)%.cpp,%.cpp.o,$(src))
ii :=  $(patsubst $(src_dir)%,%.ii,$(srcm) $(src))
dep := $(patsubst %.ii,%.ii.d,$(ii))

all: $(bin)

$(bin): $(obj)
	$(call echo,link $@ from objects $^)
	$(link)

$(obj): %.cpp.o: %.cpp.ii %.pcm
	$(call echo,compile $< to $@)
	@$(mkdir_target)
	$(compile) -fmodule-file=$*.pcm -c $<

$(bmi): %.pcm: %.cppm.ii
	$(call echo,precompile module interface $< to $@)
	@$(mkdir_target)
	$(compile) --precompile -x c++-module $<

%.cpp.ii.d: %.cpp.ii ;
%.cpp.ii: %.cpp
	$(call echo,preprocess $< to $@)
	@$(mkdir_target)
	$(preprocess)
	$(call parse_module_keyword,$*.cpp.o)
	$(call parse_import_keyword,$*.cpp.o)

%.cppm.ii.d: %.cppm.ii ;
%.cppm.ii: %.cppm
	$(call echo,preprocess module interface $< to $@)
	@$(mkdir_target)
	$(preprocess)
	$(parse_export_module_keyword)
	$(call parse_import_keyword,$*.pcm)

.PRECIOUS: %.pcm %.cpp.ii %.cppm.ii

ifneq '$(MAKECMDGOALS)' 'clean'
  include $(dep)
endif

# check whether make is in silent mode
ifeq '' '$(findstring s, $(firstword $(MAKEFLAGS)))'
  echo = @echo $${MAKE_TERMOUT:+'\033[1;36m'}'$(1)'$${MAKE_TERMOUT:+'\033[0m'}
else
  echo = :
endif

clean:
	rm -f $(bin) $(obj) $(bmi) $(ii) $(dep)

debug:
	@echo CPP $(origin CPP) $(CPP)
	@echo CXX $(origin CXX) $(CXX)
	@echo LD $(origin LD) $(LD)
	@echo GNU_GREP $(origin GNU_GREP) $(GNU_GREP)
	@echo GNU_SED $(origin GNU_SED) $(GNU_SED)
	@echo src_dir $(src_dir)
	@echo srcm $(srcm)
	@echo src $(src)
	@echo bmi $(bmi)
	@echo obj $(obj)
	@echo ii $(ii)
	@echo dep $(dep)
