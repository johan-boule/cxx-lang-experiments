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

src := $(shell cd $(src_dir) && find $(src_path) -name '*$(src_suffix)' -or -name '*$(srcm_suffix)')
srcm := $(filter %$(srcm_suffix),$(src))
src := $(filter %$(src_suffix),$(src))

vpath %$(src_suffix)  $(src_dir)
vpath %$(srcm_suffix) $(src_dir)

# beware that setting --no-builtin-variables via MAKEFLAGS does not entirely get rid of default variables
ifneq '' '$(findstring $(origin CXX), undefined default)'
  CXX := $(shell command -v clang++)
endif

CPP := $(CXX) -E
LD := $(CXX)

define check_toolchain_version # $1 = min_required_clang_major_version
  @set -e; \
  $(call echo,check toolchain version); \
  actual_clang_major_version=$$(echo __clang_major__ | $(CPP) -xc++ - | tail -n1); \
  if ! test $$actual_clang_major_version -ge $1; \
  then \
    printf '%s\n' \
      "requires clang version >= $1. \
      $(firstword $(CPP)) is version $$actual_clang_major_version."; \
    false; \
  fi
endef

mkdir_target = mkdir -p $(@D)
link       = $(LD)  -o$@ $(LDFLAGS) $+ $(LDLIBS)
compile    = $(CXX) -o$@ -std=c++2a -fmodules-ts $(module_path:%=-fprebuilt-module-path=%) $(module_map:%=-fmodule-file=%) $(CXXFLAGS)
preprocess = $(CPP) -o$@ $(include_path:%=-I$(src_dir)%) -MT$@ -MF$*.d -MMD -MP $(CPPFLAGS) $<

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
  sed -rn 's,^[ 	]*export[ 	]+module[ 	]+([^[ 	;]+)[ 	;],module_map[\1] := $*$(bmi_suffix),p' $< >> $@
endef

define parse_module_keyword
  @$(call echo,parse module keyword $< >> $@)
  sed -rn 's,^[ 	]*module[ 	]+([^[ 	;]+)[ 	;],$*$(obj_suffix): $$(module_map[\1])\n$*$(obj_suffix): private module_map := $$(module_map[\1]),p' $< >> $@
endef

define parse_import_keyword # $1 = rule target
  @$(call echo,parse import keyword $< >> $@)
  sed -rn 's,^[         ]*(export[      ]+|)import[     ]+([^[  ;]+)[   ;],$1: $$(module_map[\2])\n$1: private module_map += \2=$$(module_map[\2]),p' $< >> $@
endef

bin := $(addsuffix $(bin_suffix),$(bin))
obj := $(src:$(src_suffix)=$(obj_suffix))
bmi := $(srcm:$(srcm_suffix)=$(bmi_suffix))
ii  := $(addsuffix .ii,$(srcm) $(src)) # <- BEWARE list srcm before src!
dep := $(ii:ii=d)

default: $(bin)

all: $(bin) test

$(bin): $(obj)
	@$(call echo,link $@ from objects $+)
	$(link)

%$(obj_suffix): %$(src_suffix).ii | %$(src_suffix).d
	@$(call echo,compile $< to $@)
	$(compile) -c -xc++-cpp-output $<

%$(bmi_suffix): %$(srcm_suffix).ii | %$(srcm_suffix).d
	@$(call echo,precompile module interface $< to $@)
	$(compile) --precompile -xc++-module $<

%$(srcm_suffix).d: %$(srcm_suffix).ii
	$(parse_export_module_keyword)
	$(call parse_import_keyword,$*$(bmi_suffix))

%$(src_suffix).d: %$(src_suffix).ii
	$(parse_module_keyword)
	$(call parse_import_keyword,$*$(obj_suffix))

%.ii: % configure
	@$(call echo,preprocess $< to $@)
	@$(mkdir_target)
	$(preprocess)

configure: min_required_clang_major_version := 6
configure: env.checksum
	@$(call echo,configure)
	$(call check_toolchain_version,$(min_required_clang_major_version))
	@touch $@

%.checksum: %
	@set -e; \
	$(call echo,checksum $+ to $@); \
	md5sum $+ > $@.new; \
	if ! test -e $@ || ! cmp $@ $@.new; \
	then \
		$(call echo,checksum $+ to $@: changed); \
		mv $@.new $@; \
	else \
		$(call echo,checksum $+ to $@: no change); \
		rm $@.new; \
	fi

env: $(if $(MAKE_RESTARTS),,FORCE)
	@$(call echo,dump program timestamps and variables to $@); \
	printf '%s\n' \
		"stat makefile CPP CXX LD" \
		"$$(stat -Lc%n\ %Y \
		  $(this_makefile) \
		  $$(command -v $(firstword $(CPP))) \
		  $$(command -v $(firstword $(CXX))) \
		  $$(command -v $(firstword $(LD))))" \
		"CPP flags $(CPP) $(CPPFLAGS)" \
		"CXX flags $(CXX) $(CXXFLAGS)" \
		"LD  flags $(LD) $(LDFLAGS) $(LDLIBS)" \
		"min required version $(min_required_clang_major_version)" \
	> $@

.PHONY: FORCE

.PRECIOUS: $(ii) $(bmi)

ifneq '$(MAKECMDGOALS)' 'clean'
  include $(dep)
endif

# check whether make is in silent mode
ifeq '' '$(findstring s, $(firstword x$(MAKEFLAGS)))'
  echo = echo $${MAKE_TERMOUT:+'\033[$(if $(MAKE_RESTARTS),1;36,1;34)m'}'$1'$${MAKE_TERMOUT:+'\033[0m'}
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
	@echo CPP from $(origin CPP) = $(CPP)
	@echo
	@echo CXX from $(origin CXX) = $(CXX)
	@echo
	@echo LD from $(origin LD) = $(LD)
	@echo
	@echo src_dir = $(src_dir)
	@echo
	@echo src = $(src)
	@echo
	@echo srcm = $(srcm)
	@echo
	@echo bmi = $(bmi)
	@echo
	@echo obj = $(obj)
	@echo
	@echo ii = $(ii)
	@echo
	@echo dep = $(dep)
	@for dep in $(dep) env; \
	do \
		echo; \
		echo ================ $$dep ================; \
		if test -f $$dep; then cat $$dep; else echo no file; fi; \
	done
