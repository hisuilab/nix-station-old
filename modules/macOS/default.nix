{ homeManager
, hostConfig
, lib
, pkgs
, userProfile
, ...
}:

let
  # macOSユーザー名の取得
  username = userProfile.username;

  # Home Managerを必要とする機能の判定
  homeManagerEnabled =
    (homeManager.git or false)
    || (homeManager.zsh or false);
in
{
  # server向けmacOS設定の読み込み
  imports = [
    ./server.nix
  ];

  config = lib.mkIf homeManagerEnabled {
    # Home Manager対象ユーザーの作成
    users.users.${username} = {
      name = username;
      home = "/Users/${username}";
    } // lib.optionalAttrs (homeManager.zsh or false) {
      shell = pkgs.zsh;
    };

    # Zshのシステム有効化
    programs.zsh.enable = homeManager.zsh or false;

    # nix-darwinとHome Managerの接続
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";

      extraSpecialArgs = {
        inherit homeManager userProfile;
      };

      users.${username} = import ../home/default.nix;
    };
  };
}
