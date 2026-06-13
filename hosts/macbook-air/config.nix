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
