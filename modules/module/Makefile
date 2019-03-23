MAKEFLAGS += --no-builtin-rules --no-builtin-variables
src_dir := $(dir $(lastword $(MAKEFILE_LIST)))

.PHONY: all clean debug

bin := main
include_path := src
srcm := $(shell find $(src_dir)$(include_path)/ -name '*.cppm')
src := $(shell find $(src_dir)$(include_path)/ -name '*.cpp')

all: $(bin)

# module dependencies have to be written by hand
$(include_path)/main.pcm: $(include_path)/hello.pcm # if public dependency
$(include_path)/main.o: $(include_path)/hello.pcm # if private dependency

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
dep := $(patsubst %,%.d,$(bmi) $(obj))

mkdir_target = mkdir -p $(dir $@)
ifeq ($(origin CXX),default)
CXX  := c++
endif
compile = $(CXX) -o $@ $(dep_flags) $(module_flags) $(CPPFLAGS) $(CXXFLAGS) $<
link = $(CXX) -o $@ $(LDFLAGS) $^ $(LIBS)
dep_flags = -I$(src_dir)$(include_path) -MT $@ -MF $@.d -MMD -MP
module_flags := -std=c++2a -fmodules-ts -fprebuilt-module-path=$(include_path)

$(bin): $(obj)
	@echo '================ link $@ ================'
	$(link)

%.o: %.cpp %.o.d %.pcm
	@echo '================ compile $* ================'
	@$(mkdir_target)
	$(compile) -c -fmodule-file=$*.pcm

%.pcm: %.cppm %.pcm.d
	@echo '================ precompile $* ================'
	@$(mkdir_target)
	$(CXX) -E  $(dep_flags) $(module_flags) $(CPPFLAGS) $(CXXFLAGS) $< > $@.ii
	printf '%s\n' $<: $$(grep -E -o ' *import +[^ ]+ *;' $@.ii | sed -r -e 's: *import +::' -e 's: *;$$:.pcm:') > $@.ii.d
	$(compile) --precompile

%.d: ;
.PRECIOUS: %.d %.pcm
-include $(dep)
