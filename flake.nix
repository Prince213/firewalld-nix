{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        nixosModules =
          let
            firewalld = ./modules;
          in
          {
            default = firewalld;
            inherit firewalld;
          };
      };
      systems = [ "x86_64-linux" ];
      perSystem =
        { pkgs, ... }:
        {
          packages =
            let
              firewalld = pkgs.firewalld;
            in
            {
              default = firewalld;
              inherit firewalld;
            };
        };
    };
}
