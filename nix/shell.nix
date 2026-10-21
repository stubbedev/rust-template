{inputs, ...}: {
  perSystem = {
    config,
    craneLib,
    pkgs,
    self',
    ...
  }: let
    nightly = (inputs.rust-overlay.lib.mkRustBin {} pkgs).selectLatestNightlyWith (toolchain:
      toolchain.default.override {
        extensions = [
          "rust-analyzer"
          "rust-src"
          "rustc-codegen-cranelift-preview"
        ];
      });
  in {
    devShells.default =
      ((craneLib.overrideToolchain nightly).devShell.override {
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

        env = {
          CARGO_UNSTABLE_CODEGEN_BACKEND = "true";
          CARGO_PROFILE_DEV_CODEGEN_BACKEND = "cranelift";
        };
      };
  };
}
