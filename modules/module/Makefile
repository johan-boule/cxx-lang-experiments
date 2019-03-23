MAKEFLAGS += --no-builtin-rules --no-builtin-variables
src_dir := $(dir $(lastword $(MAKEFILE_LIST)))

.PHONY: all clean debug

bin := main
include_path := src
srcm := $(shell find $(src_dir)$(include_path)/ -name '*.cppm')
src := $(shell find $(src_dir)$(include_path)/ -name '*.cpp')

all: $(bin)

# module dependencies have to be written by hand
#$(include_path)/main.pcm: $(include_path)/hello.pcm # if public dependency
#$(include_path)/main.o: $(include_path)/hello.pcm # if private dependency

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

mkdir_target = mkdir -p $(dir $@)
ifeq ($(origin CXX),default)
CXX  := c++
endif
link = $(CXX) -o $@ $(LDFLAGS) $^ $(LIBS)
dep_flags = -I$(src_dir)$(include_path) -MT $@ -MF $@.d -MMD -MP
module_flags := -std=c++2a -fmodules-ts -fprebuilt-module-path=$(include_path)

$(bin): $(obj)
	@echo '================ link $@ ================'
	$(link)

%.o: %.ii %.pcm
	@echo '================ compile $* ================'
	@$(mkdir_target)
	$(CXX) -o $@ $(module_flags) $(CXXFLAGS) -fmodule-file=$*.pcm -c $<

%.pcm: %.cppm-ii
	@echo '================ precompile $* ================'
	@$(mkdir_target)
	$(CXX) -o $@ $(module_flags) $(CXXFLAGS) --precompile -x c++-module $<

%.ii: %.cpp
	@echo '================ preprocess $* ================'
	@$(mkdir_target)
	$(CXX) -o $@ $(dep_flags) $(CPPFLAGS) -E $<
	printf '%s\n' "$*.o: $$(grep -E '^ *import +[^ ]+ *;$$' $@ | sed -r -e 's: *import +:$(include_path)/:' -e 's: *;$$:.pcm:')" >> $@.d

%.cppm-ii: %.cppm
	@echo '================ preprocess module interface $* ================'
	@$(mkdir_target)
	$(CXX) -o $@ $(dep_flags) $(CPPFLAGS) -E $<
	printf '%s\n' "$*.pcm: $$(grep -E '^ *import +[^ ]+ *;$$' $@ | sed -r -e 's: *import +:$(include_path)/:' -e 's: *;$$:.pcm:')" >> $@.d

.PRECIOUS: %.d %.pcm %.ii %.cppm-ii
-include $(dep)
