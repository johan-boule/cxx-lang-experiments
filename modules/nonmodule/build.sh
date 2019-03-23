#! /bin/sh

set -eux &&

cd "$(dirname "$0")"

mkdir -p ++build
exec make -C ++build/ -f ../Makefile -j$(nproc) -O CXX=$gcc/bin/c++ "$@"
