{ hostConfig, ... }:

{
  system.defaults.dock = {
    autohide = hostConfig.meta.role == "laptop";
    mru-spaces = false;
    show-recents = false;
    tilesize = 48;
  };
}
