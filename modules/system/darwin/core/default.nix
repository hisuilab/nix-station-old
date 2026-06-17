{ nixpkgsUnstable, pkgs, ... }:

{
  # nix-homebrew HEAD が ruby_4_0 を要求するが nixpkgs-25.05 には未収録のため unstable から補完
  nixpkgs.overlays = [
    (final: prev: {
      ruby_4_0 = nixpkgsUnstable.legacyPackages.${prev.system}.ruby_4_0;
    })
  ];

  # Determinate Systems インストーラーと競合するため nix-darwin の Nix 管理を無効化する
  nix.enable = false;

  time.timeZone = "Asia/Tokyo";

  # nix-darwinの状態互換バージョン
  system.stateVersion = 5;
}
