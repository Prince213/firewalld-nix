{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.firewalld;
  format = pkgs.formats.keyValue { };
in
{
  options.services.firewalld.settings = lib.mkOption {
    description = ''
      firewalld config file. See {manpage}`firewalld.conf(5)`.
    '';
    default = { };
    type = lib.types.submodule {
      freeformType = format.type;
      options = {
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."firewalld/firewalld.conf" = {
      source = format.generate "firewalld.conf" cfg.settings;
    };
  };
}
