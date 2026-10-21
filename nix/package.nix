{
  perSystem = {
    cargoEnv,
    craneLib,
    lib,
    pkgs,
    ...
  }: let
    cargoToml = lib.importTOML ../Cargo.toml;

    commonArgs =
      cargoEnv
      // {
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
        // {nativeBuildInputs = [pkgs.just] ++ args.nativeBuildInputs or [];});
  in {
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
      lint = justRecipe "lint" {};
      deny = justRecipe "deny bans licenses sources" {nativeBuildInputs = [pkgs.cargo-deny];};
      shear = justRecipe "shear" {
        cargoArtifacts = null;
        nativeBuildInputs = [pkgs.cargo-shear];
      };
      test = justRecipe "test" {
        NEXTEST_PROFILE = "ci";
        nativeBuildInputs = [pkgs.cargo-nextest];
      };
    };
  };
}
