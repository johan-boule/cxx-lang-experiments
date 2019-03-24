#! /bin/sh

set -eux &&

cd "$(dirname "$0")"

mkdir -p ++build
exec make -C ++build/ -f ../Makefile -j$(getconf _NPROCESSORS_ONLN) -O "$@"
