{ pkgs }:

builtins.concatLists [
  (import ./home { inherit pkgs; })
  (import ./user-profile { inherit pkgs; })
]
