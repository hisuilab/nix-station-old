{
  meta = {
    hostname = "HisuiLab-Ubuntu-desktop";
    system = "x86_64-linux";
    builder = "home-manager";
    os = "ubuntu";
    environment = "native";
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
      enable = true;
      configFile = ../../modules/home/zed/settings.json;
    };
  };
}
