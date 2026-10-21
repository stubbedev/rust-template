{
  perSystem = {
    lib,
    pkgs,
    ...
  }: let
    cargoToml = lib.importTOML ../Cargo.toml;
  in {
    packages.default = pkgs.rustPlatform.buildRustPackage {
      pname = cargoToml.package.name;
      inherit (cargoToml.package) version;

      src = lib.fileset.toSource {
        root = ../.;
        fileset = lib.fileset.difference (lib.fileset.gitTracked ../.) (
          lib.fileset.unions [
            ../flake.nix
            ../flake.lock
            ../nix
          ]
        );
      };

      cargoLock.lockFile = ../Cargo.lock;

      useNextest = true;

      meta = {
        inherit (cargoToml.package) description;
        homepage = cargoToml.package.repository;
        license = lib.licenses.mit;
        mainProgram = cargoToml.package.name;
        platforms = lib.platforms.unix;
      };
    };
  };
}
