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

scopes/hello_world/bin/hello: | phrases
hello_world.libs := phrases
hello_world.libs_path := scopes/phrases/lib
hello_world.ld_flags := -Wl,-rpath-link=scopes/words/lib

wondermake += phrases
phrases.type := shared_lib
phrases.src := src/phrases
phrases.inherit := module_demo_common_conf

scopes/phrases/lib/libphrases.so: | words
phrases.libs := words
phrases.libs_path := scopes/words/lib

wondermake += words
words.type := shared_lib
words.src := src/words src/letters src/punctuations
words.inherit := module_demo_common_conf

default: staged-install
staged-install: scopes/hello_world/bin/hello
	mkdir -p staged-install/bin
	ln -f scopes/hello_world/bin/hello staged-install/bin/
	mkdir -p staged-install/lib
	ln -f scopes/phrases/lib/libphrases.so staged-install/lib/
	ln -f scopes/words/lib/libwords.so staged-install/lib/

$(shell mkdir -p /tmp/foo)
module_demo_common_conf.external_modules_path := external-include /tmp/foo

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
