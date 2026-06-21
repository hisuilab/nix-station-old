{ pkgs }:

builtins.concatLists [
  (import ./host-config { inherit pkgs; })
  (import ./user-profile { inherit pkgs; })
]
