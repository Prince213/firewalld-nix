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
        };
      }
    );
  };

  config = lib.mkIf cfg.enable {
    environment.etc = lib.mapAttrs' (
      name: value:
      lib.nameValuePair "firewalld/zones/${name}.xml" {
        source = format.generate "firewalld-zone-${name}.xml" {
          zone = {
          };
        };
      }
    ) cfg.zones;
  };
}
