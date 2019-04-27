# Wondermake
# Copyright 2019 Johan Boule
# This source is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

ifndef wondermake.cbase.src_suffixes.included

###############################################################################
# Source files suffixes

wondermake.cbase.cpp_suffix[c]   := i
wondermake.cbase.cxx_suffix[c]   := c
wondermake.cbase.hxx_suffix[c]   := h
wondermake.cbase.cpp_suffix[c++] := ii
wondermake.cbase.cxx_suffix[c++] := c++ cxx cpp cc C
wondermake.cbase.hxx_suffix[c++] := h++ hxx hpp hh H $(wondermake.cbase.hxx_suffix[c])
wondermake.cbase.mxx_suffix[c++] := m++ mxx mpp ixx cppm
wondermake.cbase.cpp_suffix[objective-c]   := $(wondermake.cbase.cpp_suffix[c])
wondermake.cbase.cxx_suffix[objective-c]   := $(wondermake.cbase.cxx_suffix[c]) m
wondermake.cbase.hxx_suffix[objective-c]   := $(wondermake.cbase.hxx_suffix[c])
wondermake.cbase.cpp_suffix[objective-c++] := $(wondermake.cbase.cpp_suffix[c++])
wondermake.cbase.cxx_suffix[objective-c++] := $(wondermake.cbase.cxx_suffix[c++]) mm
wondermake.cbase.hxx_suffix[objective-c++] := $(wondermake.cbase.hxx_suffix[c++])
#wondermake.cbase.mxx_suffix[objective-c++] := $(wondermake.cbase.mxx_suffix[c++])

###############################################################################
endif # ifndef wondermake.cbase.src_suffixes.included
