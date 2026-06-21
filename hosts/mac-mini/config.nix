{
  meta = {
    hostname = "HisuiLab-Mac-mini";
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
      enable = false;
      configFile = ../../modules/home/p10k/p10k.zsh;
    };
    starship = {
      enable = true;
      configFile = ../../modules/home/starship/starship.toml;
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

  darwin.dock = {
    autohide = false;
    orientation = "left";
  };

  darwin.power.sleep = "never";

  # GUI アプリ・App Store アプリは hosts/mac-mini/Brewfile で管理する。
  # install = true: nix-homebrew が Homebrew バイナリを自動インストールする
  # brewBundle = true: setup.sh が brew bundle を実行してアプリを一括導入する
  darwin.homebrew = {
    enable = true;
    install = true;
    brewBundle = true;
  };
}
