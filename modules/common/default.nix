{ pkgs, ... }:

{
  # 全ホスト共通のNixコア設定
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
  };

  # システム全体のタイムゾーン設定
  time.timeZone = "Asia/Tokyo";

  # nix-darwin / NixOS の状態互換バージョン
  # バージョン間の破壊的変更を制御するための必須のセーフティ設定
  system.stateVersion = 5;
}
