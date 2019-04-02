#! /usr/bin/make -f

MAKEFLAGS += --no-builtin-rules --no-builtin-variables

.PHONY: default all test clean debug
.DEFAULT_GOAL := default

# the directory where this makefile is
this_makefile := $(lastword $(MAKEFILE_LIST))
src_dir := $(dir $(this_makefile))

bin := hello
src_path := src
module_path :=
module_map :=
include_path :=

src_suffix := .cpp
srcm_suffix := .cppm

src  := $(shell find $(patsubst %,$(src_dir)%/,$(src_path)) -name '*$(src_suffix)' )
srcm := $(shell find $(patsubst %,$(src_dir)%/,$(src_path)) -name '*$(srcm_suffix)')

vpath %$(src_suffix)  $(src_dir)
vpath %$(srcm_suffix) $(src_dir)

# beware that setting --no-builtin-variables via MAKEFLAGS does not entirely get rid of default variables
ifneq '' '$(findstring $(origin CXX), undefined default)'
  CXX := $(shell command -v clang++)
endif

CPP := $(CXX) -E
LD := $(CXX)

define check_toolchain_version
  @$(call echo,check toolchain version); \
  actual_clang_major_version=$$(echo __clang_major__ | $(CPP) -xc++ - | tail -n1); \
  if ! test $$actual_clang_major_version -ge $(min_required_clang_major_version); \
  then \
    printf '%s\n' \
      "requires clang version >= $(min_required_clang_major_version). \
      $(firstword $(CPP)) is version $$actual_clang_major_version."; \
    false; \
  fi
endef

ifndef GNU_SED
  GNU_SED := $(shell command -v gsed || command -v sed)
  ifeq '' '$(GNU_SED)'
    $(error could not find gnu sed)
  endif
endif

mkdir_target = mkdir -p $(dir $@)
link       = $(LD)  -o$@ $(LDFLAGS) $^ $(LDLIBS)
compile    = $(CXX) -o$@ -std=c++2a -fmodules-ts $(patsubst %,-fprebuilt-module-path=%,$(module_path)) $(patsubst %,-fmodule-file=%,$(module_map)) $(CXXFLAGS)
preprocess = $(CPP) -o$@ $(patsubst %,-I$(src_dir)%,$(include_path)) -MT$@ -MF$@.d -MMD -MP $(CPPFLAGS) $<

bin_suffix :=
obj_suffix := .o
bmi_suffix := .pcm

# parsers http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2019/p1103r3.pdf
# TODO The following is not supported:
# - partitions:
#     export module foo:part;
#     module foo:part;
#     module foo;
#     import :part; // imports foo:part
# - global module fragment:
#     module;
#     #include "header"
#     export module foo;
# - header units:
#     import "header"
#     import <header>

define parse_export_module_keyword
  @$(call echo,parse export module keyword $< >> $@)
  $(GNU_SED) -rn 's,^[ 	]*export[ 	]+module[ 	]+([^[ 	;]+)[ 	;],module_map[\1] := $*$(bmi_suffix),p' $< >> $@
endef

define parse_module_keyword
  @$(call echo,parse module keyword $< >> $@)
  $(GNU_SED) -rn 's,^[ 	]*module[ 	]+([^[ 	;]+)[ 	;],$*$(obj_suffix): $$(module_map[\1])\n$*$(obj_suffix): private module_map := $$(module_map[\1]),p' $< >> $@
endef

define parse_import_keyword # $1 = rule target
  @$(call echo,parse import keyword $< >> $@)
  $(GNU_SED) -rn 's,^[         ]*(export[      ]+|)import[     ]+([^[  ;]+)[   ;],$1: $$(module_map[\2])\n$1: private module_map += \2=$$(module_map[\2]),p' $< >> $@
endef

bin := $(patsubst %,%$(bin_suffix),$(bin))
obj := $(patsubst $(src_dir)%$(src_suffix),%$(obj_suffix),$(src))
bmi := $(patsubst $(src_dir)%$(srcm_suffix),%$(bmi_suffix),$(srcm))
ii  := $(patsubst $(src_dir)%,%.ii,$(srcm) $(src))
dep := $(patsubst %.ii,%.ii.d,$(ii))

default: $(bin)

all: $(bin) test

$(bin): $(obj)
	@$(call echo,link $@ from objects $^)
	$(link)

%$(obj_suffix): %$(src_suffix).ii
	@$(call echo,compile $< to $@)
	$(compile) -c -xc++-cpp-output $<

%$(bmi_suffix): %$(srcm_suffix).ii
	@$(call echo,precompile module interface $< to $@)
	$(compile) --precompile -xc++-module $<

%$(srcm_suffix).ii.d: %$(srcm_suffix).ii
	$(parse_export_module_keyword)
	$(call parse_import_keyword,$*$(bmi_suffix))

%$(src_suffix).ii.d: %$(src_suffix).ii
	$(parse_module_keyword)
	$(call parse_import_keyword,$*$(obj_suffix))

%.ii: % configure
	@$(call echo,preprocess $< to $@)
	@$(mkdir_target)
	$(preprocess)

configure: min_required_clang_major_version := 6
configure: env.checksum
	@$(call echo,configure)
	$(check_toolchain_version)
	@touch $@

%.checksum: %
	@$(call echo,checksum $^ to $@); \
	set -e; \
	md5sum $^ > $@.new; \
	if ! test -e $@ || ! cmp $@ $@.new; \
	then \
		$(call echo,checksum $^ to $@: changed); \
		mv $@.new $@; \
	else \
		$(call echo,checksum $^ to $@: no change); \
		rm $@.new; \
	fi

env: $(if $(MAKE_RESTARTS),,FORCE)
	@$(call echo,dump env to $@)
	@printf '%s\n' \
		"makefile $$(stat -Lc%Y $(this_makefile))" \
		"CPP $$(stat -Lc%Y $$(command -v $(firstword $(CPP)))) $(CPP) $(CPPFLAGS)" \
		"CXX $$(stat -Lc%Y $$(command -v $(firstword $(CXX)))) $(CXX) $(CXXFLAGS)" \
		"LD  $$(stat -Lc%Y $$(command -v $(firstword $(LD)))) $(LD) $(LDFLAGS)" \
		"min required version $(min_required_clang_major_version)" \
	> $@

.PHONY: FORCE

.PRECIOUS: $(ii) $(bmi)

ifneq '$(MAKECMDGOALS)' 'clean'
  include $(dep)
endif

# check whether make is in silent mode
ifeq '' '$(findstring s, $(firstword x$(MAKEFLAGS)))'
  echo = echo $${MAKE_TERMOUT:+'\033[1;36m'}'$1'$${MAKE_TERMOUT:+'\033[0m'}
else
  echo := :
endif

test:: $(bin)
	@$(call echo,executing program $(<D)/$(<F))
	$(<D)/$(<F)

clean::
	@$(call echo,clean)
	rm -f $(bin) $(obj) $(bmi) $(ii) $(dep) env env.checksum env.checksum.new configure

debug::
	@$(call echo,debug: dumping variables and files contents)
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
	@for dep in $(dep) env.text; \
	do \
		echo; \
		echo ================ $$dep ================; \
		if test -f $$dep; then cat $$dep; else echo no file; fi; \
		echo; \
	done
