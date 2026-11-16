## Your company. Replace every "TODO" and run:
##   nix run .#update-exports && git add exports && nix flake check
## Option reference: https://github.com/Qezta/company-framework/blob/main/docs/options.md
{
  company = {
    root = ./.;
    decisionsDir = "decisions";

    entity = {
      name = "TODO: Company";
      legalName = "TODO: Company Private Limited";
      description = "TODO: one sentence about what the company does.";
      jurisdiction = "TODO";
    };

    roles.founder = {
      description = "Sets direction and is accountable for everything.";
      responsibilities = ["TODO: list responsibilities"];
    };

    people.founder = {
      displayName = "TODO: Your Name";
      email = "you@example.com";
      roles = ["founder"];
    };

    policies.security = {
      title = "Security";
      owner = "founder";
      doc = "policies/security.md";
    };

    processes.onboarding = {
      title = "Onboarding";
      owner = "founder";
      doc = "processes/docs/onboarding.md";
      steps = [
        {
          id = "prepare";
          title = "Prepare accounts";
          role = "founder";
          next = ["welcome"];
        }
        {
          id = "welcome";
          title = "Welcome call";
          role = "founder";
        }
      ];
    };
  };
}
