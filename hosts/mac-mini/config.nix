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
    git = false;
    zsh = false;
  };

  darwin.features = {
    # appearance = true;
    # dock = true;
    # finder = true;
    # input = true;
  };

  darwin.homebrew = {
    enable = false;
    # brews = [ "wget" ];
    # casks = [ "ghostty" ];
    # taps = [ ];
    # masApps = { };
  };
}
