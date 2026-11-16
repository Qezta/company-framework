{lib, ...}: let
  inherit (lib) mkOption types;
  nullableEmail = description:
    mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "hello@example.com";
      inherit description;
    };
in {
  options.company.entity = {
    name = mkOption {
      type = types.str;
      example = "Acme";
      description = "Everyday name of the company.";
    };
    legalName = mkOption {
      type = types.str;
      example = "Acme Widgets Private Limited";
      description = "Registered legal name.";
    };
    shortName = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "acme";
      description = "Short identifier, e.g. for prefixes and slugs.";
    };
    description = mkOption {
      type = types.str;
      example = "Makes widgets.";
      description = "One-sentence description of what the company does.";
    };
    jurisdiction = mkOption {
      type = types.str;
      example = "IN";
      description = "Country of incorporation (ISO 3166-1 alpha-2), optionally followed by a region, e.g. `IN-KA`.";
    };
    registration = mkOption {
      type = types.attrsOf types.str;
      default = {};
      example = {cin = "U00000KA2026PTC000000";};
      description = "Public registration identifiers only (never tax secrets or bank details).";
    };
    domains = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["example.com"];
      description = "Internet domains the company owns, primary first.";
    };
    contacts = {
      general = nullableEmail "General contact address.";
      security = nullableEmail "Address for security reports.";
      legal = nullableEmail "Address for legal notices.";
      privacy = nullableEmail "Address for privacy and data-protection requests.";
    };
    links = mkOption {
      type = types.attrsOf types.str;
      default = {};
      example = {
        website = "https://example.com";
        github = "https://github.com/example";
      };
      description = "Public links keyed by name.";
    };
    brand = {
      colors = mkOption {
        type = types.attrsOf types.str;
        default = {};
        example = {primary = "#ff0052";};
        description = "Brand colours as hex (`#rgb` or `#rrggbb`), keyed by name.";
      };
      fonts = mkOption {
        type = types.attrsOf types.str;
        default = {};
        example = {heading = "Roboto Flex";};
        description = "Font families keyed by role.";
      };
      logo = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "assets/logo.svg";
        description = "Logo path relative to the company repository root.";
      };
    };
  };
}
