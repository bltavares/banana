{...}: {
  imports = [./rust.nix ./nix.nix ./treefmt.nix];

  perSystem = {
    config,
    pkgs,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      name = "project";
      inputsFrom = [config.devShells.nix config.devShells.rust config.devShells.treefmt];
    };
  };
}
