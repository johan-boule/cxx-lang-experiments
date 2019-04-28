#! /usr/bin/make -f

# Note that setting --no-builtin-variables via MAKEFLAGS in the makefile has no effect.
# Also, undefining all variables that have a default origin removes useful ones too.
#MAKEFLAGS += --no-builtin-rules #--no-builtin-variables

.PHONY: default all clean
.DEFAULT_GOAL := default

module_demo_common_conf.toolchain := cbase
module_demo_common_conf.lang := c++
module_demo_common_conf.src_dir := $(dir $(lastword $(MAKEFILE_LIST)))
module_demo_common_conf.include_path := src
module_demo_common_conf.type := shared_lib
module_demo_common_conf.define := DUMMY_DEFINE=demo
module_demo_common_conf.undefine := DUMMY_DEFINE
module_demo_common_conf.cpp_flags := -std=c++2a
module_demo_common_conf.cxx_flags := -std=c++2a #-pthreads
module_demo_common_conf.ld_flags := #-pthreads
module_demo_common_conf.libs := m dl
module_demo_common_conf.pkg_config := zlib
module_demo_common_conf.external_modules_path := /tmp/foo
$(shell mkdir -p /tmp/foo)

wondermake += hello_world
hello_world.inherit := module_demo_common_conf
hello_world.name := hello
hello_world.type := executable
hello_world.src := src/main.cxx src/main.mxx
hello_world.public_deps := phrases
hello_world.external_modules_path := external-include/new_line.mxx

wondermake += phrases
phrases.inherit := module_demo_common_conf
phrases.src := src/phrases
phrases.private_deps := words

wondermake += words
words.inherit := module_demo_common_conf
words.src := src/words
words.private_deps := letters punctuations

wondermake += letters
letters.inherit := module_demo_common_conf
letters.src := src/letters

wondermake += punctuations
punctuations.inherit := module_demo_common_conf
punctuations.src := src/punctuations

include $(module_demo_common_conf.src_dir)/wondermake/wondermake.mk

default: wondermake.default
all: wondermake.all
clean: wondermake.clean

define wondermake.template
$(info {$(wondermake.template.scope)})
libs := $(foreach l,$(call wondermake.inherit_append,$(wondermake.template.scope),private_deps) $(call wondermake.inherit_append,$(wondermake.template.scope),public_deps),$(or $($(l).name),$(l)))
$(info libs -> $(libs))
endef

# Execute the template for each user-declared scope
$(foreach wondermake.template.scope,$(wondermake),$(eval $(value wondermake.template)))
