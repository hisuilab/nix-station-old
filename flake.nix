{
  description = "Nix Station";

  # 1. 外部リポジトリ（依存関係）の定義
  inputs = {
    # 安定版の NixOS / Nix チャンネル
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    # macOS環境の設定をNixで管理するためのコミュニティ標準モジュール
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # 2. システムの組み立てと出力（Outputs）
  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }@inputs:
    let
      # 対象ホストの設定（config.nix）を読み込む
      serverConfig = import ./hosts/server/config.nix { };

      # ユーザー層（default.nix）の分流ロジックを読み込む
      userProfiles = import ./user-profiles { };

      # サーバーホスト用に動的に抽出したパラメータ
      system = serverConfig.meta.system;
      userProfileName = serverConfig.userProfile.name;
      userProfile = userProfiles.loadUserProfile {
        name = userProfileName;
      };

      # ホスト設定からnix-darwin構成を生成
      mkDarwinConfiguration =
        { hostConfig
        , system ? hostConfig.meta.system
        , userProfile
        ,
        }:
        nix-darwin.lib.darwinSystem {
          inherit system;

          # macOSモジュールへのホスト・ユーザー設定の受け渡し
          specialArgs = {
            inherit hostConfig userProfile;
            homeManager = hostConfig.homeManager;
          };

          # 共通設定、Home Manager、macOS設定の統合
          modules = [
            ./modules/common/default.nix
            home-manager.darwinModules.home-manager
            ./modules/macOS/default.nix

            # ユーザープロファイルの検証
            (builtins.deepSeq userProfile {
              _module.args = { inherit userProfile; };
            })
          ];
        };

    in
    {
      # 開発環境（devShell）の定義
      # このリポジトリのコードを編集する際に便利なツールがあれば、下の `packages` に追加してください。
      devShells."${system}".default =
        let
          pkgs = nixpkgs.legacyPackages."${system}";
        in
        pkgs.mkShell {
          packages = with pkgs; [ ];
        };

      # M4 Mac mini（macOS）用のシステム定義を生成
      darwinConfigurations = {
        "${serverConfig.meta.hostname}" = mkDarwinConfiguration {
          hostConfig = serverConfig;
          inherit userProfile;
        };
      };

      # 評価テスト用の設定（nix flake check で検証可能にするための仕掛け）
      checks."${system}" = {
        # Home Managerモジュール単体の統合評価
        homeModulesEval =
          (import ./tests/home/integration.nix {
            inherit home-manager nixpkgs system;
          }).activationPackage;
        serverEval = self.darwinConfigurations.${serverConfig.meta.hostname}.system;

        tests =
          let
            pkgs = nixpkgs.legacyPackages.${system};
            results = import ./tests { inherit pkgs; };
          in
          if results == [ ]
          then pkgs.runCommand "tests-pass" { } "touch $out"
          else throw "tests failed: ${builtins.toJSON results}";
      };
    };
}
