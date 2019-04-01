#! /bin/sh

set -eux &&

cd "$(dirname "$0")"

if test -n "${IN_NIX_SHELL:-}"
then
	clang=${CXX:-$clang/bin/c++}
	gnumake=$gnumake/bin/make
	gnused=$gnused/bin/sed
	jobs=$NIX_BUILD_CORES
else
	clang=$(command -v ${CXX:-clang++})
	gnumake=$(command -v gmake || command -v make)
	gnused=$(command -v gsed || command -v sed)
	jobs=$(getconf _NPROCESSORS_ONLN)
fi

bld_dir=++build

mkdir -p $bld_dir

exec $gnumake \
	-C $bld_dir -f ../Makefile -j$jobs -O --no-print-directory \
	CXX=$clang GNU_SED=$gnused \
	"$@"

#	--warn-undefined-variables \
