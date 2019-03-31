with import <nixpkgs> {};
derivation {
	name = "cxx-lang-experiments-modules";
	src = ./.;
	inherit gnumake coreutils findutils gnused clang patchelf;
	binutils = binutils-unwrapped;
	builder = "${dash}/bin/dash";
	args = [ "-c" ''
		set -eux &&
		export PATH="$gnumake/bin:$coreutils/bin:$findutils/bin:$gnused/bin:$clang/bin:$patchelf/bin:$binutils/bin"
		make -f $src/Makefile -j$NIX_BUILD_CORES -O
		mv main $out
		patchelf --shrink-rpath $out
		strip -s $out
	'' ];
	system = builtins.currentSystem;
}
