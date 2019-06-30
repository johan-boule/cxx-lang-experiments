#! /usr/bin/make -f

# unneeded stuff
dummy.define := DUMMY_DEFINE=demo
dummy.undefine := DUMMY_DEFINE
dummy.libs := m dl
dummy.pkg_config := zlib
dummy.cxx_flags := #-pthreads
dummy.ld_flags := #-pthreads

common.inherit := dummy
common.toolchain := cbase
common.lang := c++
common.src_dir := $(dir $(lastword $(MAKEFILE_LIST)))
common.include_path := src
common.type := lib
#common.cpp_flags := -std=c++2a
#common.cxx_flags := -std=c++2a
common.version := 1.2.3

hello-world.inherit := common
hello-world.name := hello
hello-world.type := executable
hello-world.src := src/hello_world.cxx
hello-world.private_deps := phrases
hello-world.include_path := external-include
wondermake += hello-world

phrases.inherit := common
phrases.src := src/phrases/
phrases.private_deps := words
wondermake += phrases

words.inherit := common
words.src := src/words/
words.private_deps := letters punctuations
wondermake += words

letters.inherit := common
letters.type := headers
letters.src := src/letters/letters.mxx
letters.public_deps := letters-vowels letters-consonants
wondermake += letters

letters-vowels.inherit := common
letters-vowels.src := src/letters/vowels/
wondermake += letters-vowels

letters-consonants.inherit := common
letters-consonants.src := src/letters/consonants/
wondermake += letters-consonants

punctuations.inherit := common
punctuations.src := src/punctuations/
wondermake += punctuations

prog.inherit := common
prog.type := executable
prog.src := prog.cxx
prog.private_deps := lib
wondermake += prog

lib.inherit := common
lib.type := static_lib
lib.src := lib.hxx lib.cxx
wondermake += lib

include $(common.src_dir)/wondermake/main.mk

test: test-hello
test-hello: $(hello-world.out_files)
	$(call wondermake.announce,test,$@,$<)
	@''$<
