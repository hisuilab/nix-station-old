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
    gh = true;
    git = true;
    zsh = true;
  };

  darwin.features = {
    appearance = true;
    dock = true;
    finder = true;
    input = true;
  };

  darwin.homebrew = {
    enable = true;
    manageInstallation = false;
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
