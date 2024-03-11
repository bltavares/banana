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

      # TODO Run tests with craneLib.cargoNextest when I can figure out qemu-static emulated compilation fixes
      # Last error: `nix flake check --system ${cross-arch}-linux`
      # Caused by:
      #  for `project`, command `/tmp/nix-build-project-deps-0.1.0.drv-0/source/target/debug/deps/project-8c8aea5626901f1b --list --format terse` exited with code 1
      #  --- stdout:
      #  Error while loading __double-spawn: No such file or directory
      #
      project-test =
        if pkgs.stdenv.isDarwin
        then
          craneLib.cargoNexTest (commonArgs
            // {
              inherit cargoArtifacts;
            })
        else
          craneLib.cargoTest (commonArgs
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
