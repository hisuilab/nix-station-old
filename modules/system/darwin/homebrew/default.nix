{ hostConfig, lib, ... }:

let
  homebrewConfig = hostConfig.darwin.homebrew or { };
in
{
  config = lib.mkIf (homebrewConfig.enable or false) {
    environment.systemPath = lib.mkBefore [
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
    ];

    homebrew = {
      enable = true;
      taps = homebrewConfig.taps or [ ];
      brews = homebrewConfig.brews or [ ];
      casks = homebrewConfig.casks or [ ];

      onActivation = homebrewConfig.onActivation or {
        autoUpdate = true;
        upgrade = true;
        cleanup = "none";
      };
    };

    system.activationScripts.postActivation.text = lib.mkAfter ''
      echo ""
      echo "------------------------------------------------------------"
      echo " App Store アプリを mas でインストールするには:"
      echo ""
      echo "   RunCat     : mas install 1429033973"
      echo "   Xcode      : mas install 497799835"
      echo "   GarageBand : mas install 682658836"
      echo "------------------------------------------------------------"
      echo ""
    '';
  };
}
