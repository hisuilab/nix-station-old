{ homeManager
, hostConfig
, lib
, nixpkgsUnstable
, pkgs
, userProfile
, ...
}:

let
  registry = import ../../../lib/host-registry.nix;

  # macOSユーザー名の取得
  username = userProfile.username;
in
{
  # host roleに対応するnix-darwin設定の読み込み
  imports = [
    ./core/default.nix
    ./features/default.nix
    ./homebrew/default.nix
    registry.roles.${hostConfig.meta.role}.darwinModule
  ];

  options.nixStation.hostRole = lib.mkOption {
    type = lib.types.enum (builtins.attrNames registry.roles);
    readOnly = true;
    internal = true;
    description = "Selected macOS host role";
  };

  config = {
    # nix-darwin 25.05: user-scoped オプションの適用対象ユーザーを指定
    system.primaryUser = username;

    # Home Manager対象ユーザーの作成
    users.users.${username} = {
      name = username;
      home = "/Users/${username}";
    } // lib.optionalAttrs (homeManager.zsh or false) {
      shell = pkgs.zsh;
    };

    # macOS標準のZshからnix-darwinの環境変数とPATHを読み込む
    programs.zsh.enable = true;

    # nix-darwinとHome Managerの接続
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";

      extraSpecialArgs = {
        inherit homeManager hostConfig nixpkgsUnstable userProfile;
      };

      users.${username} = import ../../home/default.nix;
    };
  };
}
