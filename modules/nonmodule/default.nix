with import <nixpkgs> {};
derivation {
	name = "bohan-nonmodule";
	src = ./.;
	inherit gnumake coreutils findutils gcc patchelf;
	binutils = binutils-unwrapped;
	builder = "${dash}/bin/dash";
	args = [ "-c" ''
		set -eux &&
		export PATH="$gnumake/bin:$coreutils/bin:$findutils/bin:$gcc/bin:$patchelf/bin:$binutils/bin"
		make -f $src/Makefile -j$NIX_BUILD_CORES -O
		mv main $out
		patchelf --shrink-rpath $out
		strip -s $out
	'' ];
	system = builtins.currentSystem;
}