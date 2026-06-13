{ pkgs }:

builtins.concatLists [
  (import ./home { inherit pkgs; })
  (import ./host-config { inherit pkgs; })
  (import ./user-profile { inherit pkgs; })
]
