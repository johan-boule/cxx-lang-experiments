#! /usr/bin/make -f

wondermake += hello_world
hello_world.name := hello
hello_world.type := exe
hello_world.src := src/main.cpp src/main.cppm
hello_world.inherit := module_demo_common_conf

wondermake += phrases
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

include $(dir $(lastword $(MAKEFILE_LIST)))wondermake.mk
