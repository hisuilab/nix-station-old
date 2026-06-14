{
  meta = {
    hostname = "HisuiLab-Mac-mini";
    system = "aarch64-darwin";
    platform = "darwin";
    os = "darwin";
    environment = "native";
    role = "desktop";
  };

  userProfile.name = "hisuilab";

  homeManager = {
    cliTools = true;
    gh = true;
    git = true;
    zsh = true;
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

  darwin.homebrew = {
    enable = true;
    casks = [
      "google-chrome"
      "google-drive"

      "tailscale-app"
      "windows-app"

      "ghostty"

      "zed"
      "visual-studio-code"

      "codex-app"
      "ollama-app"

      "docker-desktop"

      "karabiner-elements"
      "logi-options+"

      "slack"
      "discord"
      "linear"
      "zoom"

      "affinity"
      "blender"
      "obs"
      # davinci-resolve は Homebrew cask から削除済み。公式サイトから手動インストール要
      "elgato-stream-deck"

      "raycast"
      "keycastr"

      "font-meslo-lg-nerd-font"
    ];
    masApps = {
      RunCat = 1429033973;
      Xcode = 497799835;
      GarageBand = 682658836;
    };
  };
}
