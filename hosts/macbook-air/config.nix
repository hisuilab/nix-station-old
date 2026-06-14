{
  meta = {
    hostname = "HisuiLab-MacBook-air";
    system = "aarch64-darwin";
    platform = "darwin";
    os = "darwin";
    environment = "native";
    role = "laptop";
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

      "docker-desktop"

      "karabiner-elements"
      "logi-options+"

      "slack"
      "discord"
      "linear"
      "zoom"

      "affinity"

      "raycast"
      "keycastr"

      "font-meslo-lg-nerd-font"
    ];
    masApps = {
      RunCat = 1429033973;
    };
  };
}
