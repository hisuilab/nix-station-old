{ nixpkgsUnstable, hostConfig, userProfile, ... }:

{
  # nix-homebrew HEAD が ruby_4_0 を要求するが nixpkgs-25.05 には未収録のため unstable から補完
  nixpkgs.overlays = [
    (final: prev: {
      ruby_4_0 = nixpkgsUnstable.legacyPackages.${prev.system}.ruby_4_0;
    })
  ];

  # activation 開始時に適用対象を表示し、guest のまま実行した場合は早期終了する
  system.activationScripts.preActivation.text = ''
    echo ""
    echo "============================================================"
    echo " Applying nix-darwin configuration"
    echo "   host    : ${hostConfig.meta.hostname}"
    echo "   user    : ${userProfile.username}"
    echo "============================================================"
    echo ""

    if [ "${userProfile.username}" = "guest" ]; then
      echo "ERROR: userProfile.name が 'guest' のままです。適用を中止します。"
      echo ""
      echo "修正手順:"
      echo "  1. ユーザープロファイルを作成する"
      echo "     cp user-profiles/guest.nix user-profiles/<your-name>.nix"
      echo "     # username / git.userName / git.userEmail を編集"
      echo ""
      echo "  2. hosts/${hostConfig.meta.hostname}/config.nix を更新する"
      echo "     userProfile.name = \"<your-name>\";"
      echo ""
      echo "  または install.sh を使うと対話形式でセットアップできます:"
      echo "     bash install.sh ${hostConfig.meta.hostname}"
      echo ""
      exit 1
    fi
  '';

  # Determinate Systems インストーラーと競合するため nix-darwin の Nix 管理を無効化する
  nix.enable = false;

  time.timeZone = "Asia/Tokyo";

  # nix-darwinの状態互換バージョン
  system.stateVersion = 5;
}
