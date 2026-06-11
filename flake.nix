{
  description = "Nix Workstation Suite (nws)";

  # 1. 外部リポジトリ（依存関係）の定義
  inputs = {
    # 安定版の NixOS / Nix チャンネル
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    # macOS環境の設定をNixで管理するためのコミュニティ標準モジュール
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # 2. システムの組み立てと出力（Outputs）
  outputs = { self, nixpkgs, nix-darwin, ... }@inputs:
    let
      # 対象ホストの設定（config.nix）を読み込む
      serverConfig = import ./hosts/server/config.nix { };

      # ユーザー層（default.nix）の分流ロジックを読み込む
      userModules = import ./user { };

      # サーバーホスト用に動的に抽出したパラメータ
      system = serverConfig.meta.system;
      username = serverConfig.user.username;
    in
    {
      # M4 Mac mini（macOS）用のシステム定義を生成
      darwinConfigurations = {
        "${serverConfig.meta.hostname}" = nix-darwin.lib.darwinSystem {
          inherit system;
          modules = [
            # 共通コア設定の適用
            ./modules/common/default.nix

            # 動的に引き当てたユーザープロファイルの適用
            (userModules.importUserProfile username)

            # 最小限のシステム設定（ホスト名）の注入
            {
              networking.hostName = serverConfig.meta.hostname;
            }
          ];
        };
      };

      # 評価テスト用の設定（nix flake check で検証可能にするための仕掛け）
      checks."${system}" = {
        serverEval = self.darwinConfigurations.server.system;
      };
    };
}
