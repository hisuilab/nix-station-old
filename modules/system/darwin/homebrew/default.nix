{ hostConfig, lib, ... }:

let
  homebrewConfig = hostConfig.darwin.homebrew or { };
in
{
  config = lib.mkIf (homebrewConfig.enable or false) {
    homebrew = {
      enable = true;
      taps = homebrewConfig.taps or [ ];
      brews = homebrewConfig.brews or [ ];
      casks = homebrewConfig.casks or [ ];
      masApps = homebrewConfig.masApps or { };

      onActivation = homebrewConfig.onActivation or {
        autoUpdate = true;
        upgrade = true;
        cleanup = "none";
      };
    };
  };
}
