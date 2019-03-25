#! /usr/bin/make -f

MAKEFLAGS += --no-builtin-rules --no-builtin-variables

.PHONY: all clean debug

src_dir := $(dir $(lastword $(MAKEFILE_LIST)))

bin := main
include_path := src

src := $(shell find $(src_dir)$(include_path)/ -name '*.cpp')
vpath %.cpp $(src_dir)

ifneq '' '$(findstring $(origin CXX), undefined default)'
  CXX := c++
endif

LD := $(CXX)

mkdir_target = mkdir -p $(dir $@)
link = $(LD) -o $@ $(LDFLAGS) $^ $(LDLIBS)
compile = $(CXX) -o $@ -I$(src_dir)$(include_path) -MT $@ -MF $*.d -MMD -MP $(CPPFLAGS) $(CXXFLAGS) -c $<

obj := $(patsubst $(src_dir)%.cpp,%.o,$(src))
dep := $(patsubst %.o,%.d,$(obj))

all: $(bin)

$(bin): $(obj)
	$(call echo,link $@ from objects $^)
	$(link)

$(dep): %.d: ;
$(obj): %.o: %.cpp %.d
	$(call echo,compile $< to $@)
	@$(mkdir_target)
	$(compile)

.PRECIOUS: %.d
  -include $(dep)

# check whether make is in silent mode
ifeq '' '$(findstring s, $(firstword x$(MAKEFLAGS)))'
  echo = @echo $${MAKE_TERMOUT:+'\033[1;36m'}'$(1)'$${MAKE_TERMOUT:+'\033[0m'}
else
  echo := @:
endif

clean:
	rm -f $(bin) $(obj) $(dep)

debug:
	@echo CXX $(origin CXX) $(CXX)
	@echo LD $(origin LD) $(LD)
	@echo src_dir $(src_dir)
	@echo src $(src)
	@echo dep $(dep)
	@echo obj $(obj)
