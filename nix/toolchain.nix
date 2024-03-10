{
  lib,
  flake-parts-lib,
  inputs,
  ...
}: {
  options.perSystem = flake-parts-lib.mkPerSystemOption ({
    inputs',
    config,
    pkgs,
    ...
  }: {
    options.project.toolchain = lib.mkOption {
      description = lib.mdDoc ''
        Which Rust (Fenix) toolchain to use when compiling the project.
      '';
      type = lib.types.package;
      default = inputs'.fenix.packages.stable;
    };

    options.project.craneLib = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = (inputs.crane.mkLib pkgs);
    };

    options.project.toolchain-packages = lib.mkOption {
      description = lib.mdDoc ''
        DevShell packages based on the rust toolchain selected
      '';
      type = lib.types.package;

      default = config.project.toolchain.withComponents [
        "cargo"
        "clippy"
        "rust-src"
        "rustc"
        "rustfmt"
      ];
    };
  });
}
