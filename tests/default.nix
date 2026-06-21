{ nixpkgsUnstable, pkgs }:

builtins.concatLists [
  (import ./modules { inherit nixpkgsUnstable pkgs; })
  (import ./lib { inherit pkgs; })
]
