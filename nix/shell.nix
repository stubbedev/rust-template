{
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    devShells.default = pkgs.mkShell {
      inputsFrom = [self'.packages.default];

      packages = with pkgs; [
        rust-analyzer
        clippy
        rustfmt
        cargo-audit
        cargo-nextest
        just
        git
        gh
      ];

      env.RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
    };

    formatter = pkgs.alejandra;
  };
}
