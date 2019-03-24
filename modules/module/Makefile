MAKEFLAGS += --no-builtin-rules --no-builtin-variables
src_dir := $(dir $(lastword $(MAKEFILE_LIST)))

.PHONY: all clean debug

bin := main
include_path := src
srcm := $(shell find $(src_dir)$(include_path)/ -name '*.cppm')
src := $(shell find $(src_dir)$(include_path)/ -name '*.cpp')

all: $(bin)

clean:
	rm -f $(bin) $(obj) $(bmi) $(dep)

debug:
	@echo src_dir $(src_dir)
	@echo srcm $(srcm)
	@echo src $(src)
	@echo bmi $(bmi)
	@echo obj $(obj)
	@echo dep $(dep)

vpath %.cppm $(src_dir)
vpath %.cpp $(src_dir)

bmi := $(patsubst $(src_dir)%.cppm,%.pcm,$(srcm))
obj := $(patsubst $(src_dir)%.cpp,%.o,$(src))
dep := $(patsubst $(src_dir)%.cpp,%.ii.d,$(src)) $(patsubst $(src_dir)%.cppm,%.cppm-ii.d,$(srcm))

ifeq ($(origin LD),default)
LD  = $(CXX)
endif

ifeq ($(origin CXX),default)
CXX  := c++
endif

link = $(LD) -o $@ $(LDFLAGS) $^ $(LIBS)
compile = $(CXX) -o $@ -std=c++2a -fmodules-ts -fprebuilt-module-path=$(include_path) $(CXXFLAGS)
preprocess = $(CXX) -o $@ -I$(src_dir)$(include_path) -MT $@ -MF $@.d -MMD -MP $(CPPFLAGS) -E $<
parse_imports = $$(grep -E '^ *import +[^ ]+ *; *$$' $@ | sed -r -e 's: *import +:$(include_path)/:' -e 's: *; *$$:.pcm:')
mkdir_target = mkdir -p $(dir $@)

$(bin): $(obj)
	@echo '================ link $@ ================'
	$(link)

%.o: %.ii %.pcm
	@echo '================ compile $* ================'
	@$(mkdir_target)
	$(compile) -fmodule-file=$*.pcm -c $<

%.pcm: %.cppm-ii
	@echo '================ precompile $* ================'
	@$(mkdir_target)
	$(compile) --precompile -x c++-module $<

%.ii.d: %.ii ;
%.ii: %.cpp
	@echo '================ preprocess $* ================'
	@$(mkdir_target)
	$(preprocess)
	printf '%s\n' "$*.o: $(parse_imports)" >> $@.d

%.cppm-ii.d: %.cppm-ii ;
%.cppm-ii: %.cppm
	@echo '================ preprocess module interface $* ================'
	@$(mkdir_target)
	$(preprocess)
	printf '%s\n' "$*.pcm: $(parse_imports)" >> $@.d

.PRECIOUS: %.pcm %.ii %.cppm-ii
-include $(dep)
