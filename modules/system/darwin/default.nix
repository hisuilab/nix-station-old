{ homeManager
, hostConfig
, lib
, nixpkgsUnstable
, pkgs
, userProfile
, ...
}:

let
  # macOSユーザー名の取得
  username = userProfile.username;
in
{
  imports = [
    ./core/default.nix
    ./features/default.nix
    ./homebrew/default.nix
  ];

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
