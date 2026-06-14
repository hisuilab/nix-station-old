{ homeManager, lib, ... }:

{
  xdg.configFile = lib.optionalAttrs (homeManager.ghostty.configFile != null) {
    "ghostty/config".source = homeManager.ghostty.configFile;
  };
}
