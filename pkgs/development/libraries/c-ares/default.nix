{ lib, stdenv, fetchurl, writeTextDir
, withCMake ? true, cmake

# sensitive downstream packages
, curl
, grpc # consumes cmake config
}:

# Note: this package is used for bootstrapping fetchurl, and thus
# cannot use fetchpatch! All mutable patches (generated by GitHub or
# cgit) that are needed here should be included directly in Nixpkgs as
# files.

stdenv.mkDerivation rec {
  pname = "c-ares";
  version = "1.19.1";

  src = fetchurl {
    url = "https://c-ares.haxx.se/download/${pname}-${version}.tar.gz";
    sha256 = "sha256-MhcAOZty7Q4DfQB0xinndB9rLsLdqSlWq+PpZx0+Jo4=";
  };

  outputs = [ "out" "dev" "man" ];

  nativeBuildInputs = lib.optionals withCMake [ cmake ];

  cmakeFlags = [] ++ lib.optionals stdenv.hostPlatform.isStatic [
    "-DCARES_SHARED=OFF"
    "-DCARES_STATIC=ON"
  ];

  enableParallelBuilding = true;

  passthru.tests = {
    inherit curl grpc;
  };

  meta = with lib; {
    description = "A C library for asynchronous DNS requests";
    homepage = "https://c-ares.haxx.se";
    changelog = "https://c-ares.org/changelog.html#${lib.replaceStrings [ "." ] [ "_" ] version}";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
