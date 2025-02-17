{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.firewalld;
  format = pkgs.formats.xml { };
in
{
  options.services.firewalld.zones = lib.mkOption {
    description = ''
      firewalld zone configuration files. See {manpage}`firewalld.zone(5)`.
    '';
    default = { };
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          version = lib.mkOption {
            type = lib.types.nullOr lib.types.nonEmptyStr;
            default = null;
          };
          target = lib.mkOption {
            type = lib.types.enum [
              "ACCEPT"
              "%%REJECT%%"
              "DROP"
            ];
            default = "%%REJECT%%";
          };
        };
      }
    );
  };

  config = lib.mkIf cfg.enable {
    environment.etc = lib.mapAttrs' (
      name: value:
      lib.nameValuePair "firewalld/zones/${name}.xml" {
        source = format.generate "firewalld-zone-${name}.xml" {
          zone =
            let
              namePrependAt = lib.mapAttrs' (name': lib.nameValuePair ("@" + name'));
            in
            lib.filterAttrsRecursive (_: value: value != null) (
              lib.mergeAttrsList [
                (namePrependAt { inherit (value) version target; })
              ]
            );
        };
      }
    ) cfg.zones;
  };
}
