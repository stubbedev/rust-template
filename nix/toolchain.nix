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
      craneLib = ((inputs.crane.mkLib pkgs).overrideToolchain rustToolchain).overrideScope (_: _: {
        stdenvSelector = p:
          if p.stdenv.hostPlatform.isLinux
          then p.stdenvAdapters.useMoldLinker p.clangStdenv
          else p.clangStdenv;
      });
      cargoEnv = {
        CARGO_UNSTABLE_CODEGEN_BACKEND = "true";
        CARGO_PROFILE_DEV_CODEGEN_BACKEND = "cranelift";
        CARGO_BUILD_RUSTFLAGS = "-Zthreads=8";
      };
    };
  };
}
