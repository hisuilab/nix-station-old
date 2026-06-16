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
    zsh = true;
    gh = true;
    git = true;
    p10k = {
      enable = true;
      configFile = ../../modules/home/p10k/p10k.zsh;
    };
    ghostty = {
      enable = true;
      configFile = ../../modules/home/ghostty/config;
    };
    zed = {
      enable = false;
      configFile = ../../modules/home/zed/settings.json;
    };
  };
}
