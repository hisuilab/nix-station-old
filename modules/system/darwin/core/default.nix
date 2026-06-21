{ nixpkgsUnstable, hostConfig, userProfile, hostname, lib, ... }:

{
  # nix-homebrew HEAD が ruby_4_0 を要求するが nixpkgs-25.05 には未収録のため unstable から補完
  nixpkgs.overlays = [
    (final: prev: {
      ruby_4_0 = nixpkgsUnstable.legacyPackages.${prev.system}.ruby_4_0;
    })
  ];

  # guest プロファイルのまま適用しようとした場合は Nix 評価時に失敗させる（ビルド前に即エラー）
  assertions = lib.optional (userProfile.username == "guest") {
    assertion = false;
    message = ''

      userProfile.name が 'guest' のままです。darwin-rebuild を中止します。

      修正手順:
        1. ~/.config/nix-station/profiles/<your-name>.toml を作成する
           username    = "<your-name>"
           [git]
           user_name  = "<Your Name>"
           user_email = "<your@email.com>"

        2. ~/.config/nix-station/instance.toml の profile を更新する
           profile = "<your-name>"
    '';
  };

  # activation 開始時に適用対象を表示する
  system.activationScripts.preActivation.text = ''
    echo ""
    echo "============================================================"
    echo " Applying nix-darwin configuration"
    echo "   host    : ${hostname}"
    echo "   user    : ${userProfile.username}"
    echo "============================================================"
    echo ""
  '';

  networking.hostName = hostname;

  # Determinate Systems インストーラーと競合するため nix-darwin の Nix 管理を無効化する
  nix.enable = false;

  time.timeZone = "Asia/Tokyo";

  # nix-darwinの状態互換バージョン
  system.stateVersion = 5;
}
