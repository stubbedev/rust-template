{inputs, ...}: {
  perSystem = {
    lib,
    pkgs,
    ...
  }: let
    cargoToml = lib.importTOML ../Cargo.toml;
    craneLib = inputs.crane.mkLib pkgs;

    commonArgs = {
      src = craneLib.cleanCargoSource ../.;
      strictDeps = true;
    };

    justRecipe = recipe: args:
      craneLib.mkCargoDerivation (commonArgs
        // {
          src = lib.fileset.toSource {
            root = ../.;
            fileset = lib.fileset.unions [
              (craneLib.fileset.commonCargoSources ../.)
              ../justfile
            ];
          };
          pnameSuffix = "-${lib.head (lib.splitString " " recipe)}";
          cargoArtifacts = craneLib.buildDepsOnly (commonArgs // {CARGO_PROFILE = "dev";});
          doInstallCargoArtifacts = false;
          buildPhaseCargoCommand = "just ${recipe}";
        }
        // args
        // {nativeBuildInputs = [pkgs.just] ++ args.nativeBuildInputs;});
  in {
    _module.args.craneLib = craneLib;

    packages.default = craneLib.buildPackage (commonArgs
      // {
        cargoArtifacts = craneLib.buildDepsOnly commonArgs;
        doCheck = false;

        meta = {
          inherit (cargoToml.package) description;
          homepage = cargoToml.package.repository;
          license = lib.licenses.mit;
          mainProgram = cargoToml.package.name;
          platforms = lib.platforms.unix;
        };
      });

    checks = {
      lint = justRecipe "lint" {nativeBuildInputs = [pkgs.clippy];};
      deny = justRecipe "deny bans licenses sources" {nativeBuildInputs = [pkgs.cargo-deny];};
      test = justRecipe "test" {
        NEXTEST_PROFILE = "ci";
        nativeBuildInputs = [pkgs.cargo-nextest];
      };
    };
  };
}
