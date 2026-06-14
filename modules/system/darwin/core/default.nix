{ ... }:

{
  # nix-darwin共通のNixコア設定
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    warn-dirty = false;
  };

  time.timeZone = "Asia/Tokyo";

  # nix-darwinの状態互換バージョン
  system.stateVersion = 5;
}
