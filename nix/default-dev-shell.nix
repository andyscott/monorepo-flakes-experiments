{ pkgs }:


let
  base-utils = with pkgs; [
    coreutils
    util-linux
    findutils
    moreutils
    gnused
    zip
  ];

  wrapped-nix-shell = with pkgs; pkgs.symlinkJoin rec {
    name = "nix-shell";
    paths = [ nix ];
    buildInputs = [ makeBinaryWrapper ];

    postBuild = ''
      wrapProgram $out/bin/nix-shell \
        --set NIX_PATH nixpkgs=flake:${../default.nix}
    '';
  };

  pre-commit-with-deps = with pkgs; pkgs.symlinkJoin rec {
    name = "hello";
    paths = [ pre-commit ];
    buildInputs = [ makeBinaryWrapper ];

    # These are the tools needed by our pre-commit hooks
    tools = [
      shellcheck
      nixpkgs-fmt
      wrapped-nix-shell
    ];

    postBuild = ''
      wrapProgram $out/bin/pre-commit \
        --set PATH ${lib.makeBinPath ([git] ++ tools)}
    '';
  };


  convenience = with pkgs; [
    pre-commit-with-deps
  ] ++ pre-commit-with-deps.tools;
in
pkgs.mkShell {

  shellHook = ''
    echo '''
    echo "$USER, welcome to the monorepo!"
    echo '''
  '';

  buildInputs = base-utils ++ convenience;
}
