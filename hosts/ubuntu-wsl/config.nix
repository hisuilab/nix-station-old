{
  meta = {
    hostname = "ubuntu-wsl";
    system = "x86_64-linux";
    platform = "home-manager";
    os = "ubuntu";
    environment = "wsl";
    role = "desktop";
  };

  userProfile.name = "guest";

  homeManager = {
    git = false;
    zsh = false;
  };
}
