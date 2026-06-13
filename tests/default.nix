{ pkgs }:

builtins.concatLists [
  (import ./darwin { inherit pkgs; })
  (import ./home { inherit pkgs; })
  (import ./host-config { inherit pkgs; })
  (import ./user-profile { inherit pkgs; })
]
