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
        DefaultZone = lib.mkOption {
          type = lib.types.nonEmptyStr;
          default = "public";
        };
        CleanupOnExit = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        CleanupModulesOnExit = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
        IPv6_rpfilter = lib.mkOption {
          type = lib.types.enum [
            "strict"
            "loose"
            "strict-forward"
            "loose-forward"
            "no"
          ];
          default = "strict";
        };
        IndividualCalls = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
        LogDenied = lib.mkOption {
          type = lib.types.enum [
            "all"
            "unicast"
            "broadcast"
            "multicast"
            "off"
          ];
          default = "off";
        };
        FirewallBackend = lib.mkOption {
          type = lib.types.enum [
            "nftables"
            "iptables"
          ];
          default = "nftables";
        };
        FlushAllOnReload = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        ReloadPolicy = lib.mkOption {
          type =
            let
              policy = lib.types.enum [
                "DROP"
                "REJECT"
                "ACCEPT"
              ];
            in
            lib.types.either policy lib.types.commas;
          default = "INPUT:DROP,FORWARD:DROP,OUTPUT:DROP";
        };
        RFC3964_IPv4 = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        StrictForwardPorts = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
        NftablesFlowtable = lib.mkOption {
          type = lib.types.separatedString " ";
          default = "off";
        };
        NftablesCounters = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
        NftablesTableOwner = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."firewalld/firewalld.conf" = {
      source = format.generate "firewalld.conf" cfg.settings;
    };
  };
}
