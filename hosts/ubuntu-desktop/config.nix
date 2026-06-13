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
  };
}
