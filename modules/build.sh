#! /bin/sh

set -eux &&

cd "$(dirname "$0")"

bld_dir=++build

mkdir -p $bld_dir

exec make \
	-C $bld_dir -f ../Makefile \
	-j$(getconf _NPROCESSORS_ONLN) -O --no-print-directory \
	"$@"
