{ nixpkgsUnstable, hostConfig, userProfile, ... }:

{
  # nix-homebrew HEAD が ruby_4_0 を要求するが nixpkgs-25.05 には未収録のため unstable から補完
  nixpkgs.overlays = [
    (final: prev: {
      ruby_4_0 = nixpkgsUnstable.legacyPackages.${prev.system}.ruby_4_0;
    })
  ];

  # activation 開始時に適用対象を表示して設定漏れを早期検出する
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
