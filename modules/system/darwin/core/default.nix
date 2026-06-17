{ nixpkgsUnstable, hostConfig, userProfile, lib, ... }:

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
        1. ユーザープロファイルを作成する
           cp user-profiles/guest.nix user-profiles/<your-name>.nix
           # username / git.userName / git.userEmail を編集

        2. hosts/<host-id>/config.nix を更新する
           userProfile.name = "<your-name>";

        または install.sh を使うと対話形式でセットアップできます:
           bash install.sh <host-id>
    '';
  };

  # activation 開始時に適用対象を表示する
  system.activationScripts.preActivation.text = ''
    echo ""
    echo "============================================================"
    echo " Applying nix-darwin configuration"
    echo "   host    : ${hostConfig.meta.hostname}"
    echo "   user    : ${userProfile.username}"
    echo "============================================================"
    echo ""
  '';

  # Determinate Systems インストーラーと競合するため nix-darwin の Nix 管理を無効化する
  nix.enable = false;

  time.timeZone = "Asia/Tokyo";

  # nix-darwinの状態互換バージョン
  system.stateVersion = 5;
}
