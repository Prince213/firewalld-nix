{
  lib,
  ...
}:

let
  inherit (lib) mkOption;
  inherit (lib.types)
    either
    enum
    port
    submodule
    ;
in
{
  portOptions = {
    options = {
      port = mkOption {
        type = either port (submodule {
          options = {
            from = mkOption { type = port; };
            to = mkOption { type = port; };
          };
        });
        apply =
          value:
          if builtins.isAttrs value then
            "${toString value.from}-${toString value.to}"
          else
            "${toString value}";
      };
      protocol = mkOption {
        type = enum [
          "tcp"
          "udp"
          "sctp"
          "dccp"
        ];
      };
    };
  };
}
