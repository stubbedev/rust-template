{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];

  perSystem = {lib, ...}: {
    treefmt = {
      projectRootFile = "flake.nix";
      programs = {
        actionlint.enable = true;
        alejandra.enable = true;
        just.enable = true;
        rustfmt = {
          enable = true;
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
