{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    rustToolchain = (inputs.rust-overlay.lib.mkRustBin {} pkgs).selectLatestNightlyWith (toolchain:
      toolchain.default.override {
        extensions = [
          "rust-analyzer"
          "rust-src"
          "rustc-codegen-cranelift-preview"
        ];
      });
  in {
    _module.args = {
      inherit rustToolchain;
      craneLib = (inputs.crane.mkLib pkgs).overrideToolchain rustToolchain;
      cargoEnv = {
        CARGO_UNSTABLE_CODEGEN_BACKEND = "true";
        CARGO_PROFILE_DEV_CODEGEN_BACKEND = "cranelift";
      };
    };
  };
}
