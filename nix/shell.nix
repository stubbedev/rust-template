{
  perSystem = {
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
          rust-analyzer
          cargo-deny
          cargo-nextest
          bacon
          just
          git
          gh
        ];

        env.RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
      };
  };
}
