{ hostConfig, ... }:

{
  system.defaults.dock = {
    autohide = hostConfig.meta.role == "laptop";
    mru-spaces = false;
    orientation =
      if hostConfig.meta.role == "laptop"
      then "bottom"
      else "left";
    show-recents = false;
    tilesize = 48;
  };
}
