{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.firewalld;
in
{
  imports = [
    ./service.nix
    ./settings.nix
  ];

  options.services.firewalld = {
    enable = lib.mkEnableOption "FirewallD";
    package = lib.mkPackageOption pkgs "firewalld" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.firewalld = {
      description = "firewalld - dynamic firewall daemon";
      before = [ "network-pre.target" ];
      wants = [ "network-pre.target" ];
      after = [
        "dbus.service"
        "polkit.service"
      ];
      conflicts = [
        "iptables.service"
        "ip6tables.service"
        "ebtables.service"
        "ipset.service"
      ];
      documentation = [ "man:firewalld(1)" ];
      aliases = [ "dbus-org.fedoraproject.FirewallD1.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        EnvironmentFile = "-/etc/sysconfig/firewalld";
        ExecStart = "${cfg.package}/bin/firewalld --nofork --nopid $FIREWALLD_ARGS";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        StandardOutput = "null";
        StandardError = "null";
        Type = "dbus";
        BusName = "org.fedoraproject.FirewallD1";
        KillMode = "mixed";
        DevicePolicy = "closed";
        KeyringMode = "private";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = false;
        ProtectKernelTunables = false;
        ProtectSystem = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
      };
    };
  };
}
