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
          stdenv = craneLib.stdenvSelector pkgs;
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
