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
    cliTools = true;
    gh = true;
    git = true;
    zsh = true;
    p10k = {
      enable = true;
      configFile = ../../modules/home/p10k/p10k.zsh;
    };
    ghostty = {
      enable = false;
      configFile = null;
    };
    zed = {
      enable = false;
      configFile = null;
    };
  };
}
