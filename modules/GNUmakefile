#! /usr/bin/make -f

wondermake += hello
hello.type := exe
hello.src := src/main.cpp src/main.cppm
hello.inherit := module_demo

wondermake += phrases
phrases.type := shared_lib
phrases.src := src/phrases src/words src/letters
phrases.inherit := module_demo

module_demo.lang := c++
module_demo.cpp :=
module_demo.cpp_flags := -std=c++2a -pthreads
module_demo.cxx :=
module_demo.cxx_flags := -std=c++2a -pthreads
module_demo.ld :=
module_demo.ld_flags :=
module_demo.ld_libs := m dl
module_demo.inherit := global

global.dummy := hahaha

#include $(dir $(lastword $(MAKEFILE_LIST)))wondermake.mk

define wondermake.inherit # $1 = scope, $2 = var, $3 = default
$(or
  $($1.$2),
  $(if
    $($1.inherit),$(call
	  wondermake.inherit,$($1.inherit),$2),$3)
)
endef

$(info [$(call wondermake.inherit,hello,dummy)])
$(info [$(call wondermake.inherit,hello,dummyx,lion)])
