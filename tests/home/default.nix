{ pkgs }:

builtins.concatLists [
  (import ./git { inherit pkgs; })
  (import ./zsh { inherit pkgs; })
]
