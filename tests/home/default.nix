{ pkgs }:

builtins.concatLists [
  (import ./git { inherit pkgs; })
  (import ./roles { inherit pkgs; })
  (import ./zsh { inherit pkgs; })
]
