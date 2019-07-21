#! /bin/sh

set -eux &&

cd "$(dirname "$0")"

bld_dir=++wondermake.build

mkdir -p $bld_dir

trace='time strace -cf'
trace=

exec $trace \
	${MAKE:-make} \
		-C $bld_dir -f ../GNUmakefile \
		-j$(($(getconf _NPROCESSORS_ONLN) * 3 / 2)) -O --no-print-directory \
		"$@"
