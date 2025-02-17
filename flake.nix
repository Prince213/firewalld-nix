{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
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
        overlays.default = self: super: {
          firewalld = super.callPackage ./package.nix { };
        };
      };
      systems = [ "x86_64-linux" ];
      perSystem =
        { system, pkgs, ... }:
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };

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
