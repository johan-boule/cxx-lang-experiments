#! /bin/sh

set -eux &&

cd "$(dirname "$0")"

bld_dir=++wondermake-build

mkdir -p $bld_dir

exec time strace -cf \
	${MAKE:-make} \
		-C $bld_dir -f ../GNUmakefile \
		-j$(($(getconf _NPROCESSORS_ONLN) * 2)) -O --no-print-directory \
		"$@"
