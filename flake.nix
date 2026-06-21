{
  description = "Nix Station";

  # 1. 外部リポジトリ（依存関係）の定義
  inputs = {
    # 安定版のNixOS / Nixチャンネル
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    # 安定版に未収録のCLIツール
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # macOSのシステム設定をNixで管理
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Homebrew本体をnix-darwinから導入
    # macOS 26 (Tahoe) サポートのため HEAD に更新
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # ユーザー環境をOS横断で管理
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # 2. host設定からシステム・ユーザー構成を生成
  outputs = { self, nixpkgs, nixpkgs-unstable, nix-darwin, nix-homebrew, home-manager, ... }:
    let
      # host設定とユーザープロファイルの読み込み
      hostConfigLib = import ./lib/host-config.nix { };
      userProfiles = import ./user-profiles { };

      # 管理対象hostの登録と必須項目の検証
      hostConfigs = import ./hosts;
      validatedHostConfigs = builtins.mapAttrs
        (hostId: config:
          hostConfigLib.validateHostConfig {
            inherit config hostId;
          })
        hostConfigs;

      lib = nixpkgs.lib;

      # builderに対応するhostのみ抽出
      darwinHosts = lib.filterAttrs (_: h: h.meta.builder == "nix-darwin") validatedHostConfigs;
      homeManagerHosts = lib.filterAttrs (_: h: h.meta.builder == "home-manager") validatedHostConfigs;

      # homeManagerHosts を meta.system でグループ化（Linux MockEval 自動展開用）
      homeManagerHostsBySystem =
        let
          systems = lib.unique (
            map (h: h.meta.system) (builtins.attrValues homeManagerHosts)
          );
        in
        builtins.listToAttrs (map
          (system: {
            name = system;
            value = lib.filterAttrs (_: h: h.meta.system == system) homeManagerHosts;
          })
          systems);

      # nix-darwinとHome Managerを統合したmacOS構成を生成
      # hostConfig は呼び出し元で validateHostConfig 済みであること
      mkDarwinConfiguration =
        { hostConfig
        , hostId
        , userProfile
        ,
        }:
        if hostConfig.meta.builder != "nix-darwin" then
          throw "host '${hostId}': darwin configuration requires meta.builder = 'nix-darwin'"
        else
          nix-darwin.lib.darwinSystem {
            system = hostConfig.meta.system;

            # nix-darwinモジュールへのhost・ユーザー設定の受け渡し
            specialArgs = {
              inherit hostConfig hostId userProfile;
              homeManager = hostConfig.homeManager;
              nixpkgsUnstable = nixpkgs-unstable;
            };

            # 共通設定、Home Manager、nix-darwin設定の統合
            modules = [
              home-manager.darwinModules.home-manager
              nix-homebrew.darwinModules.nix-homebrew
              ./modules/system/darwin/default.nix

              # Homebrew本体の導入と既存インストールの移行
              {
                nix-homebrew = {
                  enable =
                    hostConfig.darwin.homebrew.install or true;
                  enableRosetta = false;
                  user = userProfile.username;

                };
              }

              # ユーザープロファイルの全項目を評価
              (builtins.deepSeq userProfile {
                _module.args = { inherit userProfile; };
              })
            ];
          };

      # UbuntuとRaspberry Pi OS向けstandalone Home Manager構成を生成
      # hostConfig は呼び出し元で validateHostConfig 済みであること
      mkHomeConfiguration =
        { hostConfig
        , hostId
        , userProfile
        ,
        }:
        if hostConfig.meta.builder != "home-manager" then
          throw "host '${hostId}': Home Manager configuration requires meta.builder = 'home-manager'"
        else
          home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.${hostConfig.meta.system};

            # Home Managerモジュールへのhost・ユーザー設定の受け渡し
            extraSpecialArgs = {
              inherit hostConfig hostId userProfile;
              homeManager = hostConfig.homeManager;
              nixpkgsUnstable = nixpkgs-unstable;
            };

            # ユーザー環境とLinuxホームディレクトリの統合
            modules = [
              ./modules/home/default.nix
              {
                home = {
                  username = userProfile.username;
                  homeDirectory = "/home/${userProfile.username}";
                };
              }
            ];
          };

      # host名変更の影響を受けない開発・テスト用system
      checkSystem = "aarch64-darwin";

      # darwin統合テストは一度だけ import して各出力を参照する
      darwinTests = import ./tests/integration/darwin.nix {
        inherit lib mkDarwinConfiguration;
        userProfile = testUserProfile;
      };

      # リポジトリ内テスト専用プロファイル
      testUserProfile = userProfiles.loadUserProfile {
        name = "test";
      };
    in
    {
      # リポジトリ開発用shell
      devShells.${checkSystem}.default =
        nixpkgs.legacyPackages.${checkSystem}.mkShell {
          packages = [
            nixpkgs.legacyPackages.${checkSystem}.pre-commit
          ];
          shellHook = ''
            pre-commit install --install-hooks
          '';
        };

      # nix flake checkで評価するbuilder別テスト
      checks = {
        ${checkSystem} = {
          # Home Managerモジュール単体の統合評価（基本ツール）
          homeModulesEval =
            (import ./tests/integration/home.nix {
              inherit home-manager nixpkgs;
              nixpkgsUnstable = nixpkgs-unstable;
              system = checkSystem;
            }).activationPackage;

          # Home Managerモジュール統合評価（managed tools: ghostty / p10k / zed）
          homeAppConfigsEval =
            (import ./tests/integration/home.nix {
              inherit home-manager nixpkgs;
              nixpkgsUnstable = nixpkgs-unstable;
              system = checkSystem;
            }).appConfigsActivationPackage;

          # nix-darwinとHome Managerの有効構成
          darwinEnabledEval = darwinTests.enabledSystem;

          # Home Manager全機能の無効構成
          darwinDisabledEval = darwinTests.disabledSystem;

          # Git・Zshフラグによるモジュール分流
          darwinRoutingEval = darwinTests.routingSystem;

          # Homebrew設定の統合評価
          darwinHomebrewEval = darwinTests.homebrewSystem;

          # 登録済みmacOS hostのシステム評価 (userProfile はテスト用モックで代替、host追加時に自動展開)
        } // builtins.mapAttrs
          (hostId: hostConfig:
            (mkDarwinConfiguration {
              inherit hostConfig hostId;
              userProfile = testUserProfile;
            }).system
          )
          darwinHosts // {

          # host schema、Home Manager、user-profileの単体テスト
          tests =
            let
              pkgs = nixpkgs.legacyPackages.${checkSystem};
              results = import ./tests {
                inherit pkgs;
                nixpkgsUnstable = nixpkgs-unstable;
              };
            in
            if results == [ ]
            then pkgs.runCommand "tests-pass" { } "touch $out"
            else throw "tests failed: ${builtins.toJSON results}";
        };

        # 登録済みLinux hostの構成評価 (userProfile はテスト用モックで代替、host追加時に自動展開)
      } // builtins.mapAttrs
        (system: hosts:
          builtins.mapAttrs
            (hostId: hostConfig:
              (mkHomeConfiguration { inherit hostConfig hostId; userProfile = testUserProfile; }).activationPackage
            )
            hosts
        )
        homeManagerHostsBySystem;
    };
}
