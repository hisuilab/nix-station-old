{ homeManager, lib, ... }:

{
  xdg.configFile = lib.optionalAttrs (homeManager.zed.configFile != null) {
    "zed/settings.json".source = homeManager.zed.configFile;
  };
}
