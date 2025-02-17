{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.firewalld;
  format = pkgs.formats.xml { };
  portOptions = {
    options = {
      port = lib.mkOption {
        type = lib.types.either lib.types.port (
          lib.types.submodule {
            options = {
              from = lib.mkOption { type = lib.types.port; };
              to = lib.mkOption { type = lib.types.port; };
            };
          }
        );
        apply =
          value:
          if builtins.isAttrs value then
            "${toString value.from}-${toString value.to}"
          else
            "${toString value}";
      };
      protocol = lib.mkOption {
        type = lib.types.enum [
          "tcp"
          "udp"
          "sctp"
          "dccp"
        ];
      };
    };
  };
in
{
  options.services.firewalld.services = lib.mkOption {
    description = ''
      firewalld service configuration files. See {manpage}`firewalld.service(5)`.
    '';
    default = { };
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          version = lib.mkOption {
            type = lib.types.nullOr lib.types.nonEmptyStr;
            default = null;
          };
          short = lib.mkOption {
            type = lib.types.nullOr lib.types.nonEmptyStr;
            default = null;
          };
          description = lib.mkOption {
            type = lib.types.nullOr lib.types.nonEmptyStr;
            default = null;
          };
          ports = lib.mkOption {
            type = lib.types.listOf (lib.types.submodule portOptions);
            default = [ ];
          };
          protocols = lib.mkOption {
            type = lib.types.listOf lib.types.nonEmptyStr;
            default = [ ];
          };
          sourcePorts = lib.mkOption {
            type = lib.types.listOf (lib.types.submodule portOptions);
            default = [ ];
          };
        };
      }
    );
  };

  config = lib.mkIf cfg.enable {
    environment.etc = lib.mapAttrs' (
      name: value:
      lib.nameValuePair "firewalld/services/${name}.xml" {
        source = format.generate "firewalld-service-${name}.xml" {
          service =
            let
              namePrependAt = lib.mapAttrs' (name': lib.nameValuePair ("@" + name'));
            in
            lib.mergeAttrsList [
              (if value.version == null then { } else { "@version" = value.version; })
              (if value.short == null then { } else { inherit (value) short; })
              (if value.description == null then { } else { inherit (value) description; })
              { port = builtins.map namePrependAt value.ports; }
              { protocol = builtins.map (value: { "@value" = value; }) value.protocols; }
              { source-port = builtins.map namePrependAt value.sourcePorts; }
            ];
        };
      }
    ) cfg.services;
  };
}
