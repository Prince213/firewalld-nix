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
    filterNullAttrs
    mkPortOption
    mkXmlAttr
    portProtocolOptions
    protocolOption
    toXmlAttrs
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
        rules = mkOption {
          type = listOf (format.type);
          default = [ ];
        };
      };
    });
  };

  config = lib.mkIf cfg.enable {
    services.firewalld.zones = {
      block = {
        forward = true;
      };
      public = {
        forward = true;
        services = [
          "ssh"
          "dhcpv6-client"
        ];
      };
    };

    environment.etc = lib.mapAttrs' (
      name: value:
      lib.nameValuePair "firewalld/zones/${name}.xml" {
        source = format.generate "firewalld-zone-${name}.xml" {
          zone =
            let
              mkXmlAttrList = name: builtins.map (mkXmlAttr name);
              mkXmlTag = value: if value then "" else null;
            in
            filterNullAttrs (
              lib.mergeAttrsList [
                (toXmlAttrs { inherit (value) version target; })
                (mkXmlAttr "ingress-priority" value.ingressPriority)
                (mkXmlAttr "egress-priority" value.egressPriority)
                {
                  interface = mkXmlAttrList "name" value.interfaces;
                  source = builtins.map toXmlAttrs value.sources;
                  icmp-block-inversion = mkXmlTag value.icmpBlockInversion;
                  forward = mkXmlTag value.forward;
                  inherit (value) short description;
                  service = mkXmlAttrList "name" value.services;
                  port = builtins.map toXmlAttrs value.ports;
                  protocol = mkXmlAttrList "value" value.protocols;
                  icmp-block = mkXmlAttrList "name" value.icmpBlocks;
                  masquerade = mkXmlTag value.masquerade;
                  forward-port = builtins.map toXmlAttrs (builtins.map filterNullAttrs value.forwardPorts);
                  source-port = builtins.map toXmlAttrs value.sourcePorts;
                  rule = value.rules;
                }
              ]
            );
        };
      }
    ) cfg.zones;
  };
}
