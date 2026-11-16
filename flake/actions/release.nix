{pinned, ...}: {
  flake.actions-nix.workflows.".github/workflows/release-please.yml" = {
    name = "release-please";
    on.push.branches = ["main"];
    permissions = {
      contents = "write";
      pull-requests = "write";
    };
    jobs.release-please.steps = [
      {
        uses = pinned.releasePlease;
        "with" = {
          config-file = "release-please-config.json";
          manifest-file = ".release-please-manifest.json";
        };
      }
    ];
  };
}
