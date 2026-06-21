{
  meta = {
    hostname = "ubuntu-wsl";
    system = "x86_64-linux";
    builder = "home-manager";
    os = "ubuntu";
    environment = "wsl";
  };

  userProfile.name = "guest";

  homeManager = {
    cliTools = true;
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
    zsh = true;
  };
}
