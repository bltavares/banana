{...}: {
  perSystem = {
    config,
    lib,
    pkgs,
    ...
  }: {
    treefmt = {
      projectRootFile = "flake.nix";
      programs.alejandra.enable = true;
      programs.rustfmt.enable = true;
      programs.rustfmt.package = config.project.toolchain-packages;
    };

    devShells.treefmt = pkgs.mkShell {
      name = "treefmt";
      nativeBuildInputs =
        [
          config.treefmt.build.wrapper
        ]
        ++ lib.attrValues config.treefmt.build.programs;
    };
  };
}
