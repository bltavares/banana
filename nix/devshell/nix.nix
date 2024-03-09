{self, ...}: {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: let
    flake-checker = pkgs.flake-checker;
    nil = pkgs.nil;
  in {
    checks = {
      flake-checker = pkgs.stdenvNoCC.mkDerivation {
        name = "flake-checker";
        src = self;
        nativeBuildInputs = [
          flake-checker
        ];
        installPhase = ''
          flake-checker
          touch $out
        '';
      };
    };

    devShells = {
      nix = pkgs.mkShell {
        name = "nix";
        nativeBuildInputs = [
          flake-checker
          nil
        ];
      };
    };
  };
}
