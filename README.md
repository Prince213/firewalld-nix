# firewalld-nix

firewalld-nix brings [FirewallD](https://firewalld.org/) to NixOS.

## Status

### NixOS Module

- [X] `firewalld.conf(5)`: done
- [X] `firewalld.service(5)`: done
- [X] `firewalld.zone(5)`: mostly, except `rule`

## Usage

Below is a minimal `flake.nix` to get started.
See `example.nix` for an example firewalld configuration.

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    firewalld-nix = {
      url = "sourcehut:~prince213/firewalld-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, firewalld-nix, ... }:
    {
      nixosConfigurations.system = nixpkgs.lib.nixosSystem {
        modules = [
          firewalld-nix.nixosModules.default
          {
            services.firewalld.enable = true;

            # pick one
            services.firewalld.package = firewalld-nix.packages.x86_64-linux.firewalld;
            nixpkgs.overlays = [ firewalld-nix.overlays.default ];
          }
        ];
      };
    };
}
```

## License

```
Copyright 2025 Sizhe Zhao

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
