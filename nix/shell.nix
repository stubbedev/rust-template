{
  perSystem = {
    cargoEnv,
    config,
    craneLib,
    pkgs,
    self',
    ...
  }: {
    devShells.default =
      (craneLib.devShell.override {
        mkShell = pkgs.mkShell.override {
          stdenv = pkgs.stdenvAdapters.useMoldLinker pkgs.clangStdenv;
        };
      }) {
        checks = self'.checks;

        packages = with pkgs; [
          config.treefmt.build.wrapper
          cargo-deny
          cargo-nextest
          cargo-shear
          bacon
          just
          git
          gh
        ];

        env = cargoEnv;
      };
  };
}
