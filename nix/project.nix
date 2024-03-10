{self, ...}: {
  perSystem = {
    inputs',
    lib,
    pkgs,
    system,
    config,
    ...
  }: let
    craneLib = config.project.craneLib;
    src = craneLib.cleanCargoSource (craneLib.path self.outPath);
    commonArgs = {
      inherit src;
      strictDeps = true;

      buildInputs = lib.optionals pkgs.stdenv.isDarwin [
        pkgs.libiconv
      ];
    };

    cargoArtifacts = craneLib.buildDepsOnly commonArgs;

    project = craneLib.buildPackage (commonArgs
      // {
        inherit cargoArtifacts;
        doCheck = false;
      });
  in {
    checks = {
      inherit project;

      project-clippy = craneLib.cargoClippy (commonArgs
        // {
          inherit cargoArtifacts;
          cargoClippyExtraArgs = "--all-targets -- --deny warnings";
        });

      project-doc = craneLib.cargoDoc (commonArgs
        // {
          inherit cargoArtifacts;
        });

      # TODO Run tests with cargo-nextest
      my-crate-nextest = craneLib.cargoNextest (commonArgs
        // {
          inherit cargoArtifacts;

          # Work around Nextest bug: https://github.com/nextest-rs/nextest/issues/267
          # happens on emulated system compilation
          preCheck = ''
            export DYLD_FALLBACK_LIBRARY_PATH=$(${config.project.toolchain-packages}/bin/rustc --print sysroot)/lib
          '';
        });
    };

    packages = {
      default = project;
      project = project;
    };

    apps.default = {
      type = "app";
      program = "${project}/bin/project";
    };
  };
}
