# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

# Note that setting --no-builtin-variables via MAKEFLAGS in the makefile has no effect.
# Also, undefining all variables that have a default origin removes useful ones too.
MAKEFLAGS += --no-builtin-rules #--no-builtin-variables

.PHONY: default all clean
.DEFAULT_GOAL := default

include $(dir $(lastword $(MAKEFILE_LIST)))wondermake.mk

default: wondermake.default
all: wondermake.all
clean: wondermake.clean
