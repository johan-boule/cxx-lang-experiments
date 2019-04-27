#! /usr/bin/make -f

# Note that setting --no-builtin-variables via MAKEFLAGS in the makefile has no effect.
# Also, undefining all variables that have a default origin removes useful ones too.
#MAKEFLAGS += --no-builtin-rules #--no-builtin-variables

.PHONY: default all clean
.DEFAULT_GOAL := default

wondermake += hello_world
hello_world.name := hello
hello_world.type := executable
hello_world.src := src/main.cxx src/main.mxx
hello_world.inherit := module_demo_common_conf

hello_world.private_deps := phrases
staged-install/bin/hello: | phrases
hello_world.libs := phrases
hello_world.external_modules_path := external-include/new_line.mxx

wondermake += phrases
phrases.type := shared_lib
phrases.src := src/phrases
phrases.inherit := module_demo_common_conf

phrases.private_deps := words
staged-install/lib/libphrases.so: | words
phrases.libs := words

wondermake += words
words.type := shared_lib
words.src := src/words src/letters src/punctuations
words.inherit := module_demo_common_conf

$(shell mkdir -p /tmp/foo)
module_demo_common_conf.external_modules_path := /tmp/foo

module_demo_common_conf.toolchain := cbase
module_demo_common_conf.lang := c++
module_demo_common_conf.include_path := src
module_demo_common_conf.define := DUMMY_DEFINE=demo
module_demo_common_conf.undefine := DUMMY_DEFINE
module_demo_common_conf.cpp_flags := -std=c++2a
module_demo_common_conf.cxx_flags := -std=c++2a #-pthreads
module_demo_common_conf.ld_flags := #-pthreads
module_demo_common_conf.libs := m dl
module_demo_common_conf.pkg_config := zlib
module_demo_common_conf.src_dir := $(dir $(lastword $(MAKEFILE_LIST)))

include $(module_demo_common_conf.src_dir)/wondermake/wondermake.mk

default: wondermake.default
all: wondermake.all
clean: wondermake.clean

define wondermake.template
  $(info $(wondermake.template.scope))
endef

# Execute the template for each user-declared scope
$(foreach wondermake.template.scope,$(wondermake),$(eval $(value wondermake.template)))
