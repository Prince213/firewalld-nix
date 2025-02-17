{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.firewalld;
  format = pkgs.formats.xml { };
  inherit (lib) mkOption;
  inherit (lib.types)
    attrsOf
    enum
    ints
    listOf
    nonEmptyStr
    nullOr
    submodule
    ;
in
{
  options.services.firewalld.zones = mkOption {
    description = ''
      firewalld zone configuration files. See {manpage}`firewalld.zone(5)`.
    '';
    default = { };
    type = attrsOf (submodule {
      options = {
        version = mkOption {
          type = nullOr nonEmptyStr;
          default = null;
        };
        target = mkOption {
          type = enum [
            "ACCEPT"
            "%%REJECT%%"
            "DROP"
          ];
          default = "%%REJECT%%";
        };
        ingressPriority = mkOption {
          type = nullOr ints.s16;
          default = null;
        };
        egressPriority = mkOption {
          type = nullOr ints.s16;
          default = null;
        };
        interfaces = mkOption {
          type = listOf nonEmptyStr;
          default = [ ];
        };
        short = mkOption {
          type = nullOr nonEmptyStr;
          default = null;
        };
        description = mkOption {
          type = nullOr nonEmptyStr;
          default = null;
        };
        services = mkOption {
          type = listOf nonEmptyStr;
          default = [ ];
        };
      };
    });
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
                  service = builtins.map (toXmlAttr' "name") value.services;
                }
              ]
            );
        };
      }
    ) cfg.zones;
  };
}
