{
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "github:Prince213/nixpkgs/pyqt6-dbus";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-packages = {
      url = "sourcehut:~prince213/nix-packages/firewalld-qt6";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      nix-packages,
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
        overlays.default = nix-packages.overlays.firewalld;
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
