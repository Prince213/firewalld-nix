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
  inherit (common) mkXmlAttr portProtocolOptions toXmlAttrs;
  inherit (lib) mkOption;
  inherit (lib.types)
    attrsOf
    listOf
    nonEmptyStr
    nullOr
    submodule
    ;
in
{
  options.services.firewalld.services = mkOption {
    description = ''
      firewalld service configuration files. See {manpage}`firewalld.service(5)`.
    '';
    default = { };
    type = attrsOf (submodule {
      options = {
        version = mkOption {
          type = nullOr nonEmptyStr;
          default = null;
        };
        short = mkOption {
          type = nullOr nonEmptyStr;
          default = null;
        };
        description = mkOption {
          type = nullOr nonEmptyStr;
          default = null;
        };
        ports = mkOption {
          type = listOf (submodule portProtocolOptions);
          default = [ ];
        };
        protocols = mkOption {
          type = listOf nonEmptyStr;
          default = [ ];
        };
        sourcePorts = mkOption {
          type = listOf (submodule portProtocolOptions);
          default = [ ];
        };
        destination = mkOption {
          type = submodule {
            options = {
              ipv4 = mkOption {
                type = nullOr nonEmptyStr;
                default = null;
              };
              ipv6 = mkOption {
                type = nullOr nonEmptyStr;
                default = null;
              };
            };
          };
          default = { };
        };
        includes = mkOption {
          type = listOf nonEmptyStr;
          default = [ ];
        };
        helpers = mkOption {
          type = listOf nonEmptyStr;
          default = [ ];
        };
      };
    });
  };

  config = lib.mkIf cfg.enable {
    environment.etc = lib.mapAttrs' (
      name: value:
      lib.nameValuePair "firewalld/services/${name}.xml" {
        source = format.generate "firewalld-service-${name}.xml" {
          service = lib.filterAttrsRecursive (_: value: value != null) (
            lib.mergeAttrsList [
              (toXmlAttrs { inherit (value) version; })
              {
                inherit (value) short description;
                port = builtins.map toXmlAttrs value.ports;
                protocol = builtins.map (mkXmlAttr "value") value.protocols;
                source-port = builtins.map toXmlAttrs value.sourcePorts;
                destination = toXmlAttrs value.destination;
                include = builtins.map (mkXmlAttr "service") value.includes;
                helper = builtins.map (mkXmlAttr "name") value.helpers;
              }
            ]
          );
        };
      }
    ) cfg.services;
  };
}
