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
    gh = true;
    git = false;
    zsh = false;
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
      "ollama"

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
      "davinci-resolve"
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
