{ lib
, openssl
, makeWrapper
, buildGoModule
, fetchFromGitHub
, withFederationSupport ? true
}:

buildGoModule rec {
  pname = "writefreely";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "writefreely";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-7KTNimthtfmQCgyXevAEj+CZ2MS+uOby73OO1fGNXfs=";
  };

  vendorHash = "sha256-6RTshhxX+w/gdK53wCHVMpm6EkkRtEJ2/Fe7MfZ0WvY=";

  patches = [
    ./fix-go-version-error.patch
  ];

  nativeBuildInputs = lib.optional withFederationSupport makeWrapper;

  postFixup = lib.optionals withFederationSupport ''
    wrapProgram $out/bin/writefreely --prefix PATH : ${lib.makeBinPath [ openssl ]}
  '';

  ldflags = [ "-s" "-w" "-X github.com/writefreely/writefreely.softwareVer=${version}" ];

  tags = [ "sqlite" ];

  subPackages = [ "cmd/writefreely" ];

  meta = with lib; {
    description = "Build a digital writing community";
    homepage = "https://github.com/writefreely/writefreely";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ soopyc ];
  };
}
