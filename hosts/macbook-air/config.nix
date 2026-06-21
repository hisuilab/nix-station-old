{
  meta = {
    hostname = "HisuiLab-MacBook-air";
    system = "aarch64-darwin";
    builder = "nix-darwin";
    os = "macos";
    environment = "native";
  };

  userProfile.name = "guest";

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

  darwin.dock = {
    autohide = true;
    orientation = "bottom";
  };

  # GUI アプリ・App Store アプリは hosts/macbook-air/Brewfile で管理する。
  # install = false: Homebrew バイナリは既存インストールを使用する
  # brewBundle = true: setup.sh が brew bundle を実行してアプリを一括導入する
  darwin.homebrew = {
    enable = true;
    install = false;
    brewBundle = true;
  };
}
