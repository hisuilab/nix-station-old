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

      # platformに対応するhostのみ抽出
      filterHosts = platform:
        builtins.listToAttrs (
          map
            (hostId: {
              name = hostId;
              value = validatedHostConfigs.${hostId};
            })
            (builtins.filter
              (hostId: validatedHostConfigs.${hostId}.meta.platform == platform)
              (builtins.attrNames validatedHostConfigs))
        );

      darwinHosts = filterHosts "darwin";
      homeManagerHosts = filterHosts "home-manager";

      # hostが指定したユーザープロファイルを取得
      loadUserProfile = hostConfig:
        userProfiles.loadUserProfile {
          name = hostConfig.userProfile.name;
        };

      # nix-darwinとHome Managerを統合したmacOS構成を生成
      mkDarwinConfiguration =
        { hostConfig
        , hostId
        , userProfile
        ,
        }:
        let
          validatedHostConfig = hostConfigLib.validateHostConfig {
            config = hostConfig;
            inherit hostId;
          };
        in
        if validatedHostConfig.meta.platform != "darwin" then
          throw "host '${hostId}': darwin configuration requires meta.platform = 'darwin'"
        else
          nix-darwin.lib.darwinSystem {
            system = validatedHostConfig.meta.system;

            # nix-darwinモジュールへのhost・ユーザー設定の受け渡し
            specialArgs = {
              hostConfig = validatedHostConfig;
              inherit hostId userProfile;
              homeManager = validatedHostConfig.homeManager;
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
                    validatedHostConfig.darwin.homebrew.manageInstallation or true;
                  enableRosetta = validatedHostConfig.meta.system == "aarch64-darwin";
                  user = userProfile.username;
                  autoMigrate = true;
                  mutableTaps = true;
                };
              }

              # ユーザープロファイルの全項目を評価
              (builtins.deepSeq userProfile {
                _module.args = { inherit userProfile; };
              })
            ];
          };

      # UbuntuとRaspberry Pi OS向けstandalone Home Manager構成を生成
      mkHomeConfiguration =
        { hostConfig
        , hostId
        , userProfile
        ,
        }:
        let
          validatedHostConfig = hostConfigLib.validateHostConfig {
            config = hostConfig;
            inherit hostId;
          };
        in
        if validatedHostConfig.meta.platform != "home-manager" then
          throw "host '${hostId}': Home Manager configuration requires meta.platform = 'home-manager'"
        else
          home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.${validatedHostConfig.meta.system};

            # Home Managerモジュールへのhost・ユーザー設定の受け渡し
            extraSpecialArgs = {
              hostConfig = validatedHostConfig;
              inherit hostId userProfile;
              homeManager = validatedHostConfig.homeManager;
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

      # darwin platformのhostをnix-darwin構成へ変換
      mkDarwinHost = hostId: hostConfig:
        mkDarwinConfiguration {
          inherit hostConfig hostId;
          userProfile = loadUserProfile hostConfig;
        };

      # home-manager platformのhostをstandalone構成へ変換
      mkHomeHost = hostId: hostConfig:
        mkHomeConfiguration {
          inherit hostConfig hostId;
          userProfile = loadUserProfile hostConfig;
        };

      # host名変更の影響を受けない開発・テスト用system
      checkSystem = "aarch64-darwin";

      # リポジトリ内テスト専用プロファイル
      testUserProfile = userProfiles.loadUserProfile {
        name = "test";
        profilesDir = ./tests/user-profile;
      };
    in
    {
      # リポジトリ開発用shell
      devShells.${checkSystem}.default =
        nixpkgs.legacyPackages.${checkSystem}.mkShell {
          packages = [ ];
        };

      # platformごとのflake出力
      darwinConfigurations = builtins.mapAttrs mkDarwinHost darwinHosts;
      homeConfigurations = builtins.mapAttrs mkHomeHost homeManagerHosts;

      # nix flake checkで評価するplatform別テスト
      checks = {
        ${checkSystem} = {
          # Home Managerモジュール単体の統合評価
          homeModulesEval =
            (import ./tests/home/integration.nix {
              inherit home-manager nixpkgs;
              nixpkgsUnstable = nixpkgs-unstable;
              system = checkSystem;
            }).activationPackage;

          # nix-darwinとHome Managerの有効構成
          darwinEnabledEval =
            (import ./tests/darwin/integration.nix {
              inherit mkDarwinConfiguration;
              userProfile = testUserProfile;
            }).enabledSystem;

          # Home Manager全機能の無効構成
          darwinDisabledEval =
            (import ./tests/darwin/integration.nix {
              inherit mkDarwinConfiguration;
              userProfile = testUserProfile;
            }).disabledSystem;

          # Git・Zshフラグによるモジュール分流
          darwinRoutingEval =
            (import ./tests/darwin/integration.nix {
              inherit mkDarwinConfiguration;
              userProfile = testUserProfile;
            }).routingSystem;

          # desktop・laptop・serverによるrole分流
          darwinRoleRoutingEval =
            (import ./tests/darwin/integration.nix {
              inherit mkDarwinConfiguration;
              userProfile = testUserProfile;
            }).roleRoutingSystem;

          # Homebrew設定の統合評価
          darwinHomebrewEval =
            (import ./tests/darwin/integration.nix {
              inherit mkDarwinConfiguration;
              userProfile = testUserProfile;
            }).homebrewSystem;

          # 登録済みmacOS hostのシステム評価 (userProfile はテスト用モックで代替)
          macMiniMockEval = (mkDarwinConfiguration {
            hostConfig = validatedHostConfigs."mac-mini";
            hostId = "mac-mini";
            userProfile = testUserProfile;
          }).system;
          macbookAirMockEval = (mkDarwinConfiguration {
            hostConfig = validatedHostConfigs."macbook-air";
            hostId = "macbook-air";
            userProfile = testUserProfile;
          }).system;

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

        # Raspberry Pi OS向けHome Manager構成の評価
        aarch64-linux.raspberryPi5HomeEval =
          self.homeConfigurations.raspberry-pi-5.activationPackage;

        # Ubuntu向けHome Manager構成の評価
        x86_64-linux.ubuntuDesktopHomeEval =
          self.homeConfigurations.ubuntu-desktop.activationPackage;

        # Ubuntu WSL向けHome Manager構成の評価
        x86_64-linux.ubuntuWslHomeEval =
          self.homeConfigurations.ubuntu-wsl.activationPackage;
      };
    };
}
