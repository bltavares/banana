{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Self
    ## Flake Hygiene
    flake-checker = {
      url = "github:DeterminateSystems/flake-checker";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## Environment
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
        # "armv7l-linux" # TODO figure out how to make this work as many derivations don't support it
      ];
      imports = [
        inputs.treefmt-nix.flakeModule

        ./nix/toolchain.nix
        ./nix/project.nix
        ./nix/devshell
      ];
    };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    bash-prompt-prefix = "($name) ";
  };
}
