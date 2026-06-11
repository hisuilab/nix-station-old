{ pkgs, ... }:

{
  # 全ホスト共通のNixコア設定
  nix = {
    settings = {
      # Flakesと新しいNixコマンドを標準で有効化
      experimental-features = [ "nix-command" "flakes" ];

      # 警告の抑制や、ビルド時の最適化設定（必要に応じて拡張）
      warn-dirty = false;
    };

    # 各ホストで共通して使用する最小限のパッケージ（コアツール）
    # 必要に応じて、システム標準の基本コマンド（curl, git等）をここに集約可能
  };

  # システム全体のタイムゾーン設定（あなたの活動拠点に最適化）
  time.timeZone = "Asia/Tokyo";
}
