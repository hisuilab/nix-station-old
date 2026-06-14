{ pkgs }:

let
  lib = pkgs.lib;

  appearanceModule = import ../../../modules/system/darwin/features/appearance/default.nix {
    userProfile.username = "test";
  };
  laptopDockModule = import ../../../modules/system/darwin/features/dock/default.nix {
    hostConfig.meta.role = "laptop";
  };
  desktopDockModule = import ../../../modules/system/darwin/features/dock/default.nix {
    hostConfig.meta.role = "desktop";
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
    expr = appearanceModule.system.defaults.NSGlobalDomain;
    expected = {
      AppleInterfaceStyle = "Dark";
      AppleInterfaceStyleSwitchesAutomatically = false;
      AppleShowAllExtensions = true;
    };
  };

  testLaptopDockAutoHides = {
    expr = laptopDockModule.system.defaults.dock.autohide;
    expected = true;
  };

  testDesktopDockRemainsVisible = {
    expr = desktopDockModule.system.defaults.dock.autohide;
    expected = false;
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
