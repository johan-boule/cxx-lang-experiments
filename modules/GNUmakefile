#! /usr/bin/make -f

module_demo_common_conf.toolchain := cbase
module_demo_common_conf.lang := c++
module_demo_common_conf.src_dir := $(dir $(lastword $(MAKEFILE_LIST)))
module_demo_common_conf.include_path := src
module_demo_common_conf.type := lib
module_demo_common_conf.define := DUMMY_DEFINE=demo
module_demo_common_conf.undefine := DUMMY_DEFINE
module_demo_common_conf.cpp_flags := -std=c++2a
module_demo_common_conf.cxx_flags := -std=c++2a #-pthreads
module_demo_common_conf.ld_flags := #-pthreads
module_demo_common_conf.libs := m dl
module_demo_common_conf.pkg_config := zlib

wondermake += hello-world
hello-world.inherit := module_demo_common_conf
hello-world.name := hello
hello-world.type := executable
hello-world.src := src/main.cxx src/main.mxx
hello-world.private_deps := phrases
hello-world.external_modules_path := external-include/new_line.mxx

wondermake += phrases
phrases.inherit := module_demo_common_conf
phrases.src := src/phrases/
phrases.private_deps := words

wondermake += words
words.inherit := module_demo_common_conf
words.src := src/words/
words.private_deps := letters punctuations

wondermake += letters
letters.inherit := module_demo_common_conf
letters.type := headers
letters.src := src/letters/letters.mxx
letters.public_deps := letters-vowels letters-consonants

wondermake += letters-vowels
letters-vowels.inherit := module_demo_common_conf
letters-vowels.src := src/letters/vowels/

wondermake += letters-consonants
letters-consonants.inherit := module_demo_common_conf
letters-consonants.src := src/letters/consonants/

wondermake += punctuations
punctuations.inherit := module_demo_common_conf
punctuations.src := src/punctuations/

include $(module_demo_common_conf.src_dir)/wondermake/main.mk
