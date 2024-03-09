{...}: {
  perSystem = {
    pkgs,
    inputs',
    config,
    self',
    ...
  }: {
    devShells.rust = pkgs.mkShell {
      name = "rust";
      nativeBuildInputs = [
        config.project.toolchain-packages
        pkgs.rust-analyzer
        pkgs.cargo-nextest
      ];
    };
  };
}
