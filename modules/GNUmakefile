#! /usr/bin/make -f

# Note that setting --no-builtin-variables via MAKEFLAGS in the makefile has no effect.
# Also, undefining all variables that have a default origin removes useful ones too.
#MAKEFLAGS += --no-builtin-rules #--no-builtin-variables

.PHONY: default all clean
.DEFAULT_GOAL := default

wondermake += hello_world
hello_world.name := hello
hello_world.type := exe
hello_world.src := src/main.cpp src/main.cppm
#hello_world.src := src/
#hello_world.ld_libs := phrases
hello_world.inherit := module_demo_common_conf

#wondermake += phrases
phrases.type := shared_lib
phrases.src := src/phrases src/words src/letters
phrases.inherit := module_demo_common_conf

module_demo_common_conf.lang := c++
module_demo_common_conf.include_path := src
module_demo_common_conf.define := DUMMY_DEFINE=demo
module_demo_common_conf.cpp_flags := -std=c++2a -pthreads
module_demo_common_conf.cxx_flags := -std=c++2a -pthreads
module_demo_common_conf.ld_flags := -pthreads
module_demo_common_conf.ld_libs := m dl -pthreads
module_demo_common_conf.src_dir := $(dir $(lastword $(MAKEFILE_LIST)))

include $(module_demo_common_conf.src_dir)wondermake.mk

default: $(wondermake)
all: wondermake.all
clean: wondermake.clean