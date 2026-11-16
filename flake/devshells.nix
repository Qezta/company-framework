{
  inputs,
  lib,
  ...
}: {
  imports = [inputs.devshell.flakeModule];

  perSystem = {pkgs, ...}: {
    devshells.default = {
      devshell = rec {
        name = "company-framework";
        motd = "{202}Welcome to {91}${name} {202}devshell!{reset} \n $(menu)";
        packages = lib.attrsets.attrValues {
          inherit
            (pkgs)
            alejandra
            deadnix
            statix
            nixd
            jq
            yq-go
            check-jsonschema
            open-policy-agent
            regal
            hledger
            gitleaks
            reuse
            actionlint
            typos
            lychee
            ;
        };
      };
      commands = [
        {
          name = "update-exports";
          help = "Regenerate examples/acme/exports";
          command = "nix run .#update-exports";
        }
        {
          name = "check";
          help = "Run every flake check";
          command = "nix flake check -L";
        }
      ];
    };
  };
}
