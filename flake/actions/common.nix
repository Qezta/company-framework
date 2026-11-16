## Shared workflow pieces. Actions are pinned by commit SHA with the release
## tag alongside; Renovate (or a manual bump) updates both together.
{inputs, ...}: {
  imports = [inputs.actions-nix.flakeModules.default];

  _module.args = {
    pinned = {
      checkout = "actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1"; # v7.0.1
      nixInstall = "nixbuild/nix-quick-install-action@9f63be77f412a248c9d9a65a4c82cf066cdf8f0c"; # v35
      nixCache = "DeterminateSystems/magic-nix-cache-action@84c0677f58dcedf3b91f8223ce36a9ea5b3c84b7"; # v15
      uploadArtifact = "actions/upload-artifact@cf430e030ddbb5b0abf93d22962f4752f3646cd9"; # v7.0.2
      releasePlease = "googleapis/release-please-action@45996ed1f6d02564a971a2fa1b5860e934307cf7"; # v5.0.0
    };
  };

  flake.actions-nix = {
    pre-commit.enable = true;
    defaultValues.jobs = {
      runs-on = "ubuntu-latest";
      timeout-minutes = 30;
    };
  };
}
