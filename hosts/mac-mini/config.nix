{
  meta = {
    hostname = "HisuiLab-Mac-mini";
    system = "aarch64-darwin";
    platform = "darwin";
    os = "darwin";
    environment = "native";
    role = "desktop";
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
    tmux = {
      enable = true;
      configFile = ../../modules/home/tmux/tmux.conf;
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
    power = true;
  };

  # GUI アプリ・App Store アプリは hosts/mac-mini/Brewfile で管理する。
  # install = true: nix-homebrew が Homebrew バイナリを自動インストールする
  # brewBundle = true: setup.sh が brew bundle を実行してアプリを一括導入する
  darwin.homebrew = {
    enable = true;
    install = true;
    brewBundle = true;
  };
}
