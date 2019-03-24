#! /bin/sh

set -eux &&

cd "$(dirname "$0")"

if test -z "${IN_NIX_SHELL:-}"
then
	echo "$0: warning: this build script is intended to be used from inside a nixpkg environment." >&2
	clang=$(dirname $(dirname $(command -v ${CXX:-clang++}))) 
	gnumake=$(dirname $(dirname $(command -v gmake || command -v make)))
	gnused=$(dirname $(dirname $(command -v gsed || command -v sed)))
	NIX_BUILD_CORES=$(getconf _NPROCESSORS_ONLN)
fi

mkdir -p ++build
exec $gnumake/bin/make \
	-C ++build/ -f ../Makefile -j$NIX_BUILD_CORES -O --no-print-directory \
	CXX=${CXX:-$clang/bin/clang++} \
	GNU_SED=$gnused/bin/sed \
	"$@"
