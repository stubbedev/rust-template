{
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    devShells.default = (pkgs.mkShell.override {
      stdenv = pkgs.stdenvAdapters.useMoldLinker pkgs.clangStdenv;
    }) {
      inputsFrom = [self'.packages.default];

      packages = with pkgs; [
        rust-analyzer
        clippy
        rustfmt
        cargo-deny
        cargo-nextest
        bacon
        just
        git
        gh
      ];

      env.RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
    };

    formatter = pkgs.alejandra;
  };
}
