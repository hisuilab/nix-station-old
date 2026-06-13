{
  meta = {
    hostname = "HisuiLab-Raspberry-Pi-5";
    system = "aarch64-linux";
    platform = "home-manager";
    os = "raspberry-pi-os";
    environment = "native";
    role = "server";
  };

  userProfile.name = "guest";

  homeManager = {
    git = false;
    zsh = false;
  };
}
