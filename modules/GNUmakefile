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
common.type := static_lib
common.cpp_flags := -std=c++2a
common.cxx_flags := -std=c++2a

wondermake += hello-world
hello-world.inherit := common
hello-world.name := hello
hello-world.type := static_executable
hello-world.src := src/hello_world.cxx
hello-world.private_deps := phrases
hello-world.external_modules_path := external-include/new_line.mxx

wondermake += phrases
phrases.inherit := common
phrases.src := src/phrases/
phrases.private_deps := words

wondermake += words
words.inherit := common
words.src := src/words/
words.private_deps := letters punctuations

wondermake += letters
letters.inherit := common
letters.type := headers
letters.src := src/letters/letters.mxx
letters.public_deps := letters-vowels letters-consonants

wondermake += letters-vowels
letters-vowels.inherit := common
letters-vowels.type = static_lib
letters-vowels.src := src/letters/vowels/

wondermake += letters-consonants
letters-consonants.inherit := common
letters-consonants.src := src/letters/consonants/

wondermake += punctuations
punctuations.inherit := common
punctuations.src := src/punctuations/

include $(common.src_dir)/wondermake/main.mk

test: test-hello
test-hello: $(hello-world.out)
	$(call wondermake.announce,test,$@,$<)
	@''$<
