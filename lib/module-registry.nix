{
  # Home Manager ツールモジュール（homeManager.* で有効化）

  "home/cli-tools" = {
    path = ../modules/home/cli-tools;
    description = "基本CLIツール（fzf、jq、ripgrepなど）";
    os = [ "macos" "ubuntu" "raspberry-pi-os" ];
  };

  "home/gh" = {
    path = ../modules/home/gh;
    description = "GitHub CLI設定";
    os = [ "macos" "ubuntu" "raspberry-pi-os" ];
  };

  "home/git" = {
    path = ../modules/home/git;
    description = "Git設定（identity、delta、エイリアス）";
    os = [ "macos" "ubuntu" "raspberry-pi-os" ];
  };

  "home/ghostty" = {
    path = ../modules/home/ghostty;
    description = "Ghosttyターミナル設定ファイル配置";
    os = [ "macos" "ubuntu" "raspberry-pi-os" ];
  };

  "home/p10k" = {
    path = ../modules/home/p10k;
    description = "Powerlevel10kプロンプト設定ファイル配置";
    os = [ "macos" "ubuntu" "raspberry-pi-os" ];
  };

  "home/starship" = {
    path = ../modules/home/starship;
    description = "Starshipプロンプト設定ファイル配置";
    os = [ "macos" "ubuntu" "raspberry-pi-os" ];
  };

  "home/tmux" = {
    path = ../modules/home/tmux;
    description = "tmux設定ファイル配置";
    os = [ "macos" "ubuntu" "raspberry-pi-os" ];
  };

  "home/zed" = {
    path = ../modules/home/zed;
    description = "Zedエディタ設定ファイル配置";
    os = [ "macos" "ubuntu" "raspberry-pi-os" ];
  };

  "home/zsh" = {
    path = ../modules/home/zsh;
    description = "Zsh設定（補完、プラグイン）";
    os = [ "macos" "ubuntu" "raspberry-pi-os" ];
  };

  # Home Managerプラットフォームモジュール（os で自動選択）

  "home/platforms/darwin" = {
    path = ../modules/home/platforms/darwin;
    description = "macOS向けホームディレクトリ設定";
    os = [ "macos" ];
  };

  "home/platforms/ubuntu" = {
    path = ../modules/home/platforms/ubuntu;
    description = "Ubuntu向けホームディレクトリ設定";
    os = [ "ubuntu" ];
  };

  "home/platforms/raspberry-pi-os" = {
    path = ../modules/home/platforms/raspberry-pi-os;
    description = "Raspberry Pi OS向けホームディレクトリ設定";
    os = [ "raspberry-pi-os" ];
  };

  # Home Manager環境モジュール（environment で自動選択）

  "home/environments/native" = {
    path = ../modules/home/environments/native;
    description = "ネイティブ環境向け設定";
    os = [ "macos" "ubuntu" "raspberry-pi-os" ];
  };

  "home/environments/wsl" = {
    path = ../modules/home/environments/wsl;
    description = "WSL環境向け設定";
    os = [ "ubuntu" ];
  };

  # nix-darwin システムフィーチャーモジュール（darwin.features.* で有効化）

  "system/darwin/features/appearance" = {
    path = ../modules/system/darwin/features/appearance;
    description = "macOS外観設定（ダークモード、アクセントカラー）";
    os = [ "macos" ];
  };

  "system/darwin/features/dock" = {
    path = ../modules/system/darwin/features/dock;
    description = "Dock表示・配置設定";
    os = [ "macos" ];
  };

  "system/darwin/features/finder" = {
    path = ../modules/system/darwin/features/finder;
    description = "Finder表示設定";
    os = [ "macos" ];
  };

  "system/darwin/features/input" = {
    path = ../modules/system/darwin/features/input;
    description = "キーボード・トラックパッド設定";
    os = [ "macos" ];
  };

  "system/darwin/features/power" = {
    path = ../modules/system/darwin/features/power;
    description = "スリープ・電源管理設定";
    os = [ "macos" ];
  };
}
