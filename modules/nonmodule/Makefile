MAKEFLAGS += --no-builtin-rules --no-builtin-variables
src_dir := $(dir $(lastword $(MAKEFILE_LIST)))

.PHONY: all clean debug

bin := main
include_path := src
src := $(shell find $(src_dir)$(include_path)/ -name '*.cpp')

all: $(bin)

clean:
	rm -f $(bin) $(obj) $(dep)

debug:
	@echo src_dir $(src_dir)
	@echo src $(src)
	@echo dep $(dep)
	@echo obj $(obj)

vpath %.cpp $(src_dir)

dep := $(patsubst $(src_dir)%.cpp,%.d,$(src))
obj := $(patsubst %.d,%.o,$(dep))

mkdir_target = mkdir -p $(dir $@)
ifeq ($(origin CXX),default)
CXX  := c++
endif
compile = $(CXX) -o $@ $(dep_flags) $(CPPFLAGS) $(CXXFLAGS) -c $<
link = $(CXX) -o $@ $(LDFLAGS) $^ $(LIBS)
dep_flags = -I$(src_dir)$(include_path) -MT $@ -MF $*.d -MMD -MP

$(bin): $(obj)
	@echo '================ link $@ ================'
	$(link)

%.o: %.cpp %.d
	@echo '================ compile $* ================'
	@$(mkdir_target)
	$(compile)

%.d: ;
.PRECIOUS: %.d
-include $(dep)
