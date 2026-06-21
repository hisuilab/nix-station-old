{ nixpkgsUnstable, pkgs }:

builtins.concatLists [
  (import ./home { inherit nixpkgsUnstable pkgs; })
  (import ./system/darwin { inherit pkgs; })
]
