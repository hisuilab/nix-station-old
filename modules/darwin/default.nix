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
  # host roleに対応するnix-darwin設定の読み込み
  imports =
    if hostConfig.meta.role == "server" then
      [ ./roles/server.nix ]
    else if hostConfig.meta.role == "laptop" then
      [ ./roles/laptop.nix ]
    else if hostConfig.meta.role == "desktop" then
      [ ./roles/desktop.nix ]
    else
      throw "unsupported nix-darwin host role: ${hostConfig.meta.role}";

  options.nixStation.hostRole = lib.mkOption {
    type = lib.types.enum [ "desktop" "laptop" "server" ];
    readOnly = true;
    internal = true;
    description = "Selected macOS host role";
  };

  config = lib.mkMerge [
    {
      # nix-darwinの状態互換バージョン
      system.stateVersion = 5;
    }

    (lib.mkIf homeManagerEnabled {
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
          inherit homeManager hostConfig userProfile;
        };

        users.${username} = import ../home/default.nix;
      };
    })
  ];
}
