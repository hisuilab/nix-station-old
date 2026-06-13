{
  meta = {
    hostname = "HisuiLab-MacBook-air";
    system = "aarch64-darwin";
    platform = "darwin";
    role = "laptop";
  };

  userProfile.name = "guest";

  homeManager = {
    git = false;
    zsh = false;
  };
}
