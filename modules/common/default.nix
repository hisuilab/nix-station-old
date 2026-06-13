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
}
