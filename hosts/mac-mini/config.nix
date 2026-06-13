{
  meta = {
    hostname = "HisuiLab-Mac-mini";
    system = "aarch64-darwin";
    platform = "darwin";
    role = "desktop";
  };

  userProfile.name = "guest";

  homeManager = {
    git = false;
    zsh = false;
  };
}
