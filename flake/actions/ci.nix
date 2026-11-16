{pinned, ...}: {
  flake.actions-nix.workflows.".github/workflows/ci.yml" = {
    name = "CI";
    on = {
      push.branches = ["main"];
      pull_request = {};
      workflow_dispatch = {};
    };
    permissions.contents = "read";
    ## Instantiate the template for real and check it against this checkout.
    jobs.template = {
      steps = [
        {
          name = "Checkout";
          uses = pinned.checkout;
          "with".persist-credentials = false;
        }
        {
          name = "Install Nix";
          uses = pinned.nixInstall;
        }
        {
          name = "Nix cache";
          uses = pinned.nixCache;
        }
        {
          name = "nix flake init + check";
          run = ''
            dir="$RUNNER_TEMP/company"
            mkdir -p "$dir" && cd "$dir"
            nix flake init -t "path:$GITHUB_WORKSPACE#default"
            git init -q && git add -A
            nix flake check -L --override-input company-framework "path:$GITHUB_WORKSPACE"
          '';
        }
      ];
    };
    jobs.check = {
      steps = [
        {
          name = "Checkout";
          uses = pinned.checkout;
          "with".persist-credentials = false;
        }
        {
          name = "Install Nix";
          uses = pinned.nixInstall;
        }
        {
          name = "Nix cache";
          uses = pinned.nixCache;
        }
        {
          name = "nix flake check";
          run = "nix flake check -L";
        }
        {
          name = "Build exports";
          run = "nix build .#exports -o exports";
        }
        {
          name = "Upload exports";
          uses = pinned.uploadArtifact;
          "with" = {
            name = "exports";
            path = "exports/";
          };
        }
      ];
    };
  };
}
