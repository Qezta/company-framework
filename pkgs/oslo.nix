## OpenSLO's reference validator. OpenSLO publishes no JSON Schema, so
## `oslo validate` is the closest thing to an official conformance check.
## Not in nixpkgs; pinned to a release tag with fixed-output hashes.
{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "oslo";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "OpenSLO";
    repo = "oslo";
    rev = "v${version}";
    hash = "sha256-b/44vFXzksCcl15a9OrdErQz0SHd0C4SV6sMp7OcNro=";
  };

  vendorHash = "sha256-gT8qmpTsI6+CBjB4Qhp+UNgp6qgF0H2Ul09fEWw4VyU=";
  subPackages = ["cmd/oslo"];

  meta = {
    description = "CLI for validating and converting OpenSLO manifests";
    homepage = "https://github.com/OpenSLO/oslo";
    license = lib.licenses.asl20;
    mainProgram = "oslo";
  };
}
