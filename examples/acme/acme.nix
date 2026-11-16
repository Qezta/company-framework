## A FICTIONAL company that exercises every option. All names, addresses and
## identifiers are invented; domains use the reserved example.* TLDs (RFC 2606).
{
  company = {
    asOf = "2026-11-16";

    entity = {
      name = "Acme";
      legalName = "Acme Widgets Private Limited";
      shortName = "acme";
      description = "Acme makes configurable widgets for small workshops.";
      jurisdiction = "IN-KA";
      registration.cin = "EXAMPLE-CIN-0000";
      domains = ["acme.example" "acme-widgets.example"];
      contacts = {
        general = "hello@acme.example";
        security = "security@acme.example";
        legal = "legal@acme.example";
        privacy = "privacy@acme.example";
      };
      links = {
        website = "https://acme.example";
        github = "https://github.com/acme-example";
      };
      brand = {
        colors = {
          primary = "#ff0052";
          background = "#060606";
          text = "#ccc";
        };
        fonts = {
          heading = "Roboto Flex";
          body = "Roboto";
        };
        logo = "assets/logo.svg";
      };
    };

    roles = {
      founder = {
        description = "Sets direction and is ultimately accountable for everything.";
        githubTeam = "founders";
        githubPermission = "admin";
        responsibilities = ["Company strategy" "Final approval on hires and spend"];
      };
      engineering = {
        description = "Builds and runs the product.";
        parent = "founder";
        githubTeam = "engineering";
        githubPermission = "maintain";
        responsibilities = ["Ship and operate the product" "Review pull requests"];
      };
      platform = {
        description = "Owns infrastructure, CI and developer tooling.";
        parent = "engineering";
        githubTeam = "platform";
        githubPermission = "push";
        responsibilities = ["Keep infrastructure declarative" "Run incident response"];
      };
      operations = {
        description = "Keeps the business running day to day.";
        parent = "founder";
        responsibilities = ["Vendor management" "Customer support"];
      };
      finance = {
        description = "Books, invoicing and tax.";
        parent = "operations";
        responsibilities = ["Monthly close" "GST filings"];
      };
    };

    people = {
      asha = {
        displayName = "Asha Rao";
        email = "asha@acme.example";
        githubUser = "asha-acme-example";
        roles = ["founder" "engineering"];
        startDate = "2026-01-05";
      };
      bilal = {
        displayName = "Bilal Khan";
        email = "bilal@acme.example";
        githubUser = "bilal-acme-example";
        roles = ["platform"];
        status = "onboarding";
        startDate = "2026-11-10";
      };
      chen = {
        displayName = "Chen Li";
        email = "chen@acme.example";
        roles = ["finance"];
        startDate = "2026-03-01";
      };
      dana = {
        displayName = "Dana Iyer";
        email = "dana@acme.example";
        githubUser = "dana-acme-example";
        roles = ["engineering"];
        status = "former";
        startDate = "2026-02-01";
        endDate = "2026-08-31";
      };
    };

    domains = {
      web = {
        description = "Everything customers see in a browser.";
        owner = "engineering";
      };
      platform = {
        description = "Infrastructure and internal tooling.";
        owner = "platform";
      };
    };

    systems = {
      website = {
        description = "Marketing website at acme.example.";
        type = "website";
        lifecycle = "production";
        domain = "web";
        owner = "engineering";
        repo = "acme-example/website";
        codeowners = [
          {
            pattern = "*";
            owners = ["engineering"];
          }
          {
            pattern = "/content/legal/";
            owners = ["founder"];
          }
        ];
        dependsOn = ["ui" "infra"];
        links.live = "https://acme.example";
      };
      ui = {
        description = "Shared component library.";
        type = "library";
        domain = "web";
        owner = "engineering";
        repo = "acme-example/ui";
      };
      infra = {
        description = "DNS, repositories and CI as code.";
        type = "infrastructure";
        lifecycle = "production";
        domain = "platform";
        owner = "platform";
        repo = "acme-example/infra";
      };
      handbook = {
        description = "Internal handbook.";
        type = "documentation";
        lifecycle = "deprecated";
        owner = "operations";
      };
    };
  };
}
