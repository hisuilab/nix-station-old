{
  meta = {
    hostname = "HisuiLab-Ubuntu-desktop";
    system = "x86_64-linux";
    platform = "home-manager";
    os = "ubuntu";
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
