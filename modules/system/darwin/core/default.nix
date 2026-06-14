{ nixpkgsUnstable, pkgs, ... }:

{
  # nix-homebrew HEAD が ruby_4_0 を要求するが nixpkgs-25.05 には未収録のため unstable から補完
  nixpkgs.overlays = [
    (final: prev: {
      ruby_4_0 = nixpkgsUnstable.legacyPackages.${prev.system}.ruby_4_0;
    })
  ];

  # nix-darwin共通のNixコア設定
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    warn-dirty = false;
  };

  time.timeZone = "Asia/Tokyo";

  # nix-darwinの状態互換バージョン
  system.stateVersion = 5;
}
