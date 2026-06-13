{ pkgs }:

builtins.concatLists [
  (import ./environments { inherit pkgs; })
  (import ./git { inherit pkgs; })
  (import ./platforms { inherit pkgs; })
  (import ./roles { inherit pkgs; })
  (import ./zsh { inherit pkgs; })
]
