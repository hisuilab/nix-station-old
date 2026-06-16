{ hostConfig, hostId, lib, ... }:

let
  homebrewConfig = hostConfig.darwin.homebrew or { };
in
{
  # Homebrew のインストール管理のみ nix-homebrew に委譲する。
  # パッケージ管理（GUI アプリ・App Store アプリ）は Brewfile で行い、
  # darwin-rebuild switch 後に手動で brew bundle を実行する。
  # CLI ツールは Home Manager で管理する。
  config = lib.mkIf (homebrewConfig.enable or false) {
    environment.systemPath = lib.mkBefore [
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
    ];

    system.activationScripts.postActivation.text = lib.mkAfter ''
      echo ""
      echo "============================================================"
      echo " nix-station の管理対象:"
      echo "   CLI ツール  → Home Manager (nix)"
      echo "   GUI アプリ  → Brewfile (brew cask / mas)"
      echo "============================================================"
      echo " Homebrew パッケージの適用が必要な場合:"
      echo ""
      echo "   brew bundle --file hosts/${hostId}/Brewfile"
      echo ""
      echo " App Store アプリも Brewfile の mas 行で管理できます。"
      echo "============================================================"
      echo ""
    '';
  };
}
