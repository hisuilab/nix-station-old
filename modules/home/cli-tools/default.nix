{ nixpkgsUnstable, pkgs, ... }:

let
  claudeCodePkgs = import nixpkgsUnstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfreePredicate = package:
      pkgs.lib.getName package == "claude-code";
  };
in
{
  home.packages = with pkgs; [
    # --- ファイル / テキスト操作 ---
    fd # find の高速代替
    ripgrep # grep の高速代替 (rg)

    # --- 開発ワークフロー ---
    devbox # 再現可能な開発環境
    just # タスクランナー (Makefile 代替)
    pre-commit # コミット前自動リント

    claudeCodePkgs.claude-code # AIコーディングエージェント
  ];

  programs = {
    bat.enable = true;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    eza = {
      enable = true;
      enableZshIntegration = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh.shellAliases = {
      ls = "eza";
      ll = "eza -lh --git";
      la = "eza -lah --git";
      tree = "eza --tree --icons";
    };
  };
}
