{
  description = "rust-template - starting point for new Rust projects";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    crane.url = "github:ipetkov/crane";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    flake-parts,
    nixpkgs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [
        ./nix/package.nix
        ./nix/shell.nix
        ./nix/treefmt.nix
      ];
      flake.templates.default = {
        path = ./.;
        inherit ((nixpkgs.lib.importTOML ./Cargo.toml).package) description;
      };
    };
}
