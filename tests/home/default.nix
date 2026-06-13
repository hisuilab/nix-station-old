{ nixpkgsUnstable, pkgs }:

builtins.concatLists [
  (import ./cli-tools { inherit nixpkgsUnstable pkgs; })
  (import ./environments { inherit pkgs; })
  (import ./gh { inherit pkgs; })
  (import ./git { inherit pkgs; })
  (import ./platforms { inherit pkgs; })
  (import ./roles { inherit pkgs; })
  (import ./zsh { inherit pkgs; })
]
