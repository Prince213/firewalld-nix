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
          ingressPriority = lib.mkOption {
            type = lib.types.nullOr lib.types.ints.s16;
            default = null;
          };
          egressPriority = lib.mkOption {
            type = lib.types.nullOr lib.types.ints.s16;
            default = null;
          };
          interfaces = lib.mkOption {
            type = lib.types.listOf lib.types.nonEmptyStr;
            default = [ ];
          };
          short = lib.mkOption {
            type = lib.types.nullOr lib.types.nonEmptyStr;
            default = null;
          };
          description = lib.mkOption {
            type = lib.types.nullOr lib.types.nonEmptyStr;
            default = null;
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
              toXmlAttr = lib.mapAttrs' (name': lib.nameValuePair ("@" + name'));
              toXmlAttr' = name: value: { "@${name}" = value; };
            in
            lib.filterAttrsRecursive (_: value: value != null) (
              lib.mergeAttrsList [
                (toXmlAttr { inherit (value) version target; })
                (toXmlAttr' "ingress-priority" value.ingressPriority)
                (toXmlAttr' "egress-priority" value.egressPriority)
                {
                  interface = builtins.map (toXmlAttr' "name") value.interfaces;
                  inherit (value) short description;
                }
              ]
            );
        };
      }
    ) cfg.zones;
  };
}
