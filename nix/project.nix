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

      # https://github.com/ipetkov/crane/issues/385
      doNotLinkInheritedArtifacts = true;
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

      # Run tests with cargo-nextest
      # Consider setting `doCheck = false` on `my-crate` if you do not want
      # the tests to run twice
      my-crate-nextest = craneLib.cargoTest (commonArgs
        // {
          inherit cargoArtifacts;
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
