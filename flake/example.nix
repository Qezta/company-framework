## Dogfood the flake module on the fictional example company, so its exports
## get the same drift check every consumer gets.
{
  imports = [../flake-module.nix];

  company = {
    modules = [../examples/acme/acme.nix];
    exportsDir = "examples/acme/exports";
    mcp.module = "examples/acme/acme.nix";
  };
}
