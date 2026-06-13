{
  meta = {
    hostname = "HisuiLab-Ubuntu-desktop";
    system = "x86_64-linux";
    platform = "home-manager";
    role = "server";
  };

  userProfile.name = "guest";

  homeManager = {
    git = false;
    zsh = false;
  };
}
