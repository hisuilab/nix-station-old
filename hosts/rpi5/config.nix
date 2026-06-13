{
  meta = {
    hostname = "HisuiLab-rpi5";
    system = "aarch64-linux";
    platform = "home-manager";
    role = "server";
  };

  userProfile.name = "guest";

  homeManager = {
    git = false;
    zsh = false;
  };
}
