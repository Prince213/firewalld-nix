{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.firewalld;
  format = pkgs.formats.xml { };
  common = import ./common.nix { inherit lib; };
  inherit (common)
    mkPortOption
    mkXmlAttr
    portProtocolOptions
    protocolOption
    ;
  inherit (lib) mkOption;
  inherit (lib.types)
    attrTag
    attrsOf
    bool
    enum
    ints
    listOf
    nonEmptyStr
    nullOr
    strMatching
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
        sources = mkOption {
          type = listOf (attrTag {
            address = mkOption {
              type = nonEmptyStr;
            };
            mac = mkOption {
              type = strMatching "([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}";
            };
            ipset = mkOption {
              type = nonEmptyStr;
            };
          });
          default = [ ];
        };
        icmpBlockInversion = mkOption {
          type = bool;
          default = false;
        };
        forward = mkOption {
          type = bool;
          default = false;
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
        ports = mkOption {
          type = listOf (submodule portProtocolOptions);
          default = [ ];
        };
        protocols = mkOption {
          type = listOf nonEmptyStr;
          default = [ ];
        };
        icmpBlocks = mkOption {
          type = listOf nonEmptyStr;
          default = [ ];
        };
        masquerade = mkOption {
          type = bool;
          default = false;
        };
        forwardPorts = mkOption {
          type = listOf (submodule {
            options = {
              port = mkPortOption { };
              protocol = protocolOption;
              to-port = (mkPortOption { optional = true; }) // {
                default = null;
              };
              to-addr = mkOption {
                type = nullOr nonEmptyStr;
                default = null;
              };
            };
          });
          default = [ ];
        };
        sourcePorts = mkOption {
          type = listOf (submodule portProtocolOptions);
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
            in
            lib.filterAttrsRecursive (_: value: value != null) (
              lib.mergeAttrsList [
                (toXmlAttr { inherit (value) version target; })
                (mkXmlAttr "ingress-priority" value.ingressPriority)
                (mkXmlAttr "egress-priority" value.egressPriority)
                {
                  interface = builtins.map (mkXmlAttr "name") value.interfaces;
                  source = builtins.map toXmlAttr value.sources;
                  icmp-block-inversion = if value.icmpBlockInversion then "" else null;
                  forward = if value.forward then "" else null;
                  inherit (value) short description;
                  service = builtins.map (mkXmlAttr "name") value.services;
                  port = builtins.map toXmlAttr value.ports;
                  protocol = builtins.map (mkXmlAttr "value") value.protocols;
                  icmp-block = builtins.map (mkXmlAttr "name") value.icmpBlocks;
                  masquerade = if value.masquerade then "" else null;
                  forward-port = builtins.map toXmlAttr (
                    builtins.map (lib.filterAttrsRecursive (_: value: value != null)) value.forwardPorts
                  );
                  source-port = builtins.map toXmlAttr value.sourcePorts;
                }
              ]
            );
        };
      }
    ) cfg.zones;
  };
}
