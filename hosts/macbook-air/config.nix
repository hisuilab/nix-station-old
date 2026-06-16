{
  meta = {
    hostname = "HisuiLab-MacBook-air";
    system = "aarch64-darwin";
    platform = "darwin";
    os = "darwin";
    environment = "native";
    role = "laptop";
  };

  userProfile.name = "hisuilab";

  homeManager = {
    cliTools = true;
    zsh = true;
    gh = true;
    git = true;
    p10k = {
      enable = true;
      configFile = ../../modules/home/p10k/p10k.zsh;
    };
    ghostty = {
      enable = true;
      configFile = ../../modules/home/ghostty/config;
    };
    zed = {
      enable = true;
      configFile = ../../modules/home/zed/settings.json;
    };
  };

  darwin.features = {
    appearance = true;
    dock = true;
    finder = true;
    input = true;
  };

  # GUI アプリ・App Store アプリは hosts/macbook-air/Brewfile で管理する。
  # パッケージ適用: darwin-rebuild switch 後に brew bundle --file hosts/macbook-air/Brewfile
  # manageInstallation = false: Homebrew は既存インストールを使用する
  darwin.homebrew = {
    enable = true;
    manageInstallation = false;
  };
}
