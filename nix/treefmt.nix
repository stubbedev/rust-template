{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];

  perSystem = {
    lib,
    rustToolchain,
    ...
  }: {
    treefmt = {
      projectRootFile = "flake.nix";
      programs = {
        actionlint.enable = true;
        alejandra.enable = true;
        just.enable = true;
        rustfmt = {
          enable = true;
          package = rustToolchain;
          inherit ((lib.importTOML ../Cargo.toml).package) edition;
        };
        taplo.enable = true;
        yamlfmt = {
          enable = true;
          settings.formatter.retain_line_breaks_single = true;
        };
      };
    };
  };
}
