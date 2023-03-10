{
  description = "flakes, in a monorepo?";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?rev=8c66bd1b68f4708c90dcc97c6f7052a5a7b33257";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, flake-utils, flake-compat }:
    flake-utils.lib.eachDefaultSystem (system:
    let

      overlay1 = self: super: {
        overlay-hi = self.writeScriptBin "overlay-hi"
          ''
            echo hi!
          '';
      };

      overlays = [
        overlay1
        #(import ./nix/overlays/pipe)
        #(import ./nix/overlays/trim-pulumi-bin)
      ];
      pkgs = import nixpkgs {
        inherit system overlays;
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      devShells.default = import ./nix/default-dev-shell.nix { inherit pkgs; };

      packages = pkgs;
    });
}
