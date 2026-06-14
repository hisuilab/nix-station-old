{ pkgs }:

let
  lib = pkgs.lib;

  appearanceModule = import ../../../modules/system/darwin/features/appearance/default.nix {
    userProfile.username = "test";
  };
  laptopDockModule = import ../../../modules/system/darwin/features/dock/default.nix {
    hostConfig.meta.role = "laptop";
    inherit lib pkgs;
    userProfile.username = "test";
  };
  desktopDockModule = import ../../../modules/system/darwin/features/dock/default.nix {
    hostConfig.meta.role = "desktop";
    inherit lib pkgs;
    userProfile.username = "test";
  };
  finderModule = import ../../../modules/system/darwin/features/finder/default.nix {
    inherit pkgs;
    userProfile.username = "test";
  };
  inputModule = import ../../../modules/system/darwin/features/input/default.nix { };

  selectedModules = features:
    (import ../../../modules/system/darwin/features/default.nix {
      hostConfig.darwin = { inherit features; };
      inherit lib;
    }).imports;
in
lib.runTests {
  testFinderFeatureSelectsFinderModule = {
    expr = builtins.elem
      ../../../modules/system/darwin/features/finder/default.nix
      (selectedModules { finder = true; });
    expected = true;
  };

  testDisabledFeatureIsNotSelected = {
    expr = builtins.elem
      ../../../modules/system/darwin/features/dock/default.nix
      (selectedModules { dock = false; });
    expected = false;
  };

  testAppearanceDefaultsAreConfigured = {
    expr = {
      global = appearanceModule.system.defaults.NSGlobalDomain;
      airDrop = appearanceModule.system.defaults.controlcenter.AirDrop;
    };
    expected = {
      global = {
        AppleInterfaceStyle = "Dark";
        AppleInterfaceStyleSwitchesAutomatically = false;
        AppleShowAllExtensions = true;
      };
      airDrop = false;
    };
  };

  testLaptopDockAutoHides = {
    expr = {
      autohide = laptopDockModule.system.defaults.dock.autohide;
      orientation = laptopDockModule.system.defaults.dock.orientation;
    };
    expected = {
      autohide = true;
      orientation = "bottom";
    };
  };

  testDesktopDockRemainsVisible = {
    expr = {
      autohide = desktopDockModule.system.defaults.dock.autohide;
      orientation = desktopDockModule.system.defaults.dock.orientation;
    };
    expected = {
      autohide = false;
      orientation = "left";
    };
  };

  testDockActivationConfiguresApplications = {
    expr = {
      apps = lib.hasInfix
        (lib.escapeShellArgs [
          "/System/Applications/Apps.app"
          "/Applications/Google Chrome.app"
          "/Applications/Slack.app"
          "/Applications/Discord.app"
          "/System/Applications/Photos.app"
          "/System/Applications/Notes.app"
          "/Applications/Visual Studio Code.app"
          "/Applications/Zed.app"
          "/Applications/Codex.app"
          "/Applications/Ghostty.app"
          "/Applications/Docker.app/Contents/MacOS/Docker Desktop.app"
          "/System/Applications/System Settings.app"
        ])
        laptopDockModule.system.activationScripts.postActivation.text;
      refreshesPreferences = lib.hasInfix
        "killall cfprefsd"
        laptopDockModule.system.activationScripts.postActivation.text;
      removesExistingApps = lib.hasInfix
        ''dockutil --remove all --no-restart "$dock_plist"''
        laptopDockModule.system.activationScripts.postActivation.text;
      targetsUserPreferences = lib.hasInfix
        ''dock_plist="/Users/test/Library/Preferences/com.apple.dock.plist"''
        laptopDockModule.system.activationScripts.postActivation.text;
    };
    expected = {
      apps = true;
      refreshesPreferences = true;
      removesExistingApps = true;
      targetsUserPreferences = true;
    };
  };

  testDockActivationConfiguresDefaultBrowser = {
    expr = lib.hasInfix
      "defaultbrowser chrome || true"
      laptopDockModule.system.activationScripts.postActivation.text;
    expected = true;
  };

  testAppearanceActivationConfiguresUserPreferences = {
    expr = {
      multicolor = lib.hasInfix
        "defaults delete NSGlobalDomain AppleAccentColor"
        appearanceModule.system.activationScripts.postActivation.text;
      siriMenu = lib.hasInfix
        "defaults write com.apple.Siri StatusMenuVisible -bool false"
        appearanceModule.system.activationScripts.postActivation.text;
      spotlightMenu = lib.hasInfix
        "defaults -currentHost write com.apple.Spotlight MenuItemHidden -bool true"
        appearanceModule.system.activationScripts.postActivation.text;
      spotlightShortcut = lib.hasInfix
        ''-c "Set :AppleSymbolicHotKeys:64:enabled false"''
        appearanceModule.system.activationScripts.postActivation.text;
    };
    expected = {
      multicolor = true;
      siriMenu = true;
      spotlightMenu = true;
      spotlightShortcut = true;
    };
  };

  testFinderDefaultsAreConfigured = {
    expr = finderModule.system.defaults.finder;
    expected = {
      AppleShowAllFiles = true;
      FXPreferredViewStyle = "Nlsv";
      ShowPathbar = true;
      ShowStatusBar = true;
    };
  };

  testFinderSidebarStartsWithHome = {
    expr = lib.hasInfix
      "add Home \"file:///Users/test\"\n\nfor directory in Desktop Downloads Documents Pictures Music Movies Projects; do"
      finderModule.system.activationScripts.postActivation.text;
    expected = true;
  };

  testInputDefaultsAreConfigured = {
    expr = {
      fnKey = inputModule.system.defaults.hitoolbox.AppleFnUsageType;
      mouseSpeed =
        inputModule.system.defaults.CustomUserPreferences.NSGlobalDomain."com.apple.mouse.scaling";
      trackpad = inputModule.system.defaults.trackpad;
      trackpadSpeed =
        inputModule.system.defaults.NSGlobalDomain."com.apple.trackpad.scaling";
    };
    expected = {
      fnKey = "Do Nothing";
      mouseSpeed = 3.0;
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
      };
      trackpadSpeed = 3.0;
    };
  };

  testUnknownFeatureIsRejected = {
    expr = (builtins.tryEval (builtins.deepSeq
      (selectedModules { unknown = true; })
      true)).success;
    expected = false;
  };
}
