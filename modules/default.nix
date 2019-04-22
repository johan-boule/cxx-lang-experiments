with import <nixpkgs> {};
derivation {
	name = "cxx-lang-experiments-modules";
	src = ./.;
	clang = clang_8;
	inherit gnumake coreutils findutils gnused patchelf;
	binutils = binutils-unwrapped;
	pkg_config = pkg-config;
	builder = "${dash}/bin/dash";
	args = [ "-c" ''
		set -eux &&
		export PATH="$gnumake/bin:$coreutils/bin:$findutils/bin:$gnused/bin:$clang/bin:$patchelf/bin:$binutils/bin:$pkg_config/bin"
		make -f $src/GNUmakefile -j$NIX_BUILD_CORES -O
		mv hello $out
		patchelf --shrink-rpath $out
		strip -s $out
	'' ];
	system = builtins.currentSystem;
}
