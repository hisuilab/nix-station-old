{ pkgs }:

let
  lib = pkgs.lib;
  hostConfigLib = import ../../lib/host-config.nix { };

  validConfig = {
    meta = {
      system = "aarch64-darwin";
      platform = "darwin";
      os = "darwin";
      environment = "native";
      role = "desktop";
    };
    userProfile.name = "guest";
    homeManager = {
      git = false;
      zsh = false;
    };
  };

  validate = hostId: config:
    hostConfigLib.validateHostConfig {
      inherit config hostId;
    };

  canValidate = hostId: config:
    (builtins.tryEval (
      builtins.deepSeq (validate hostId config) true
    )).success;
in
lib.runTests {
  testValidHostConfigLoads = {
    expr = canValidate "mac-mini" validConfig;
    expected = true;
  };

  testHomeManagerMayBeOmitted = {
    expr = (validate
      "mac-mini"
      (builtins.removeAttrs validConfig [ "homeManager" ])).homeManager;
    expected = { };
  };

  testAdditionalHomeManagerFlagsAreAccepted = {
    expr = (validate "mac-mini" (lib.recursiveUpdate validConfig {
      homeManager.vim = true;
    })).homeManager.vim;
    expected = true;
  };

  testNonBooleanHomeManagerFlagIsRejected = {
    expr = canValidate "mac-mini" (lib.recursiveUpdate validConfig {
      homeManager.vim = "yes";
    });
    expected = false;
  };

  testDarwinFeaturesDefaultToEmpty = {
    expr = (validate "mac-mini" validConfig).darwin.features;
    expected = { };
  };

  testDarwinHomebrewDefaultsToEmpty = {
    expr = (validate "mac-mini" validConfig).darwin.homebrew;
    expected = { };
  };

  testDarwinHomebrewEnableMustBeBoolean = {
    expr = canValidate "mac-mini" (lib.recursiveUpdate validConfig {
      darwin.homebrew.enable = "yes";
    });
    expected = false;
  };

  testInvalidHostIdIsRejected = {
    expr = canValidate "HisuiLab Mac mini" validConfig;
    expected = false;
  };

  testHostnameDefaultsToHostId = {
    expr = (validate "mac-mini" validConfig).meta.hostname;
    expected = "mac-mini";
  };

  testExplicitHostnameIsPreserved = {
    expr = (validate "mac-mini" (lib.recursiveUpdate validConfig {
      meta.hostname = "HisuiLab-Mac-mini";
    })).meta.hostname;
    expected = "HisuiLab-Mac-mini";
  };

  testMissingRoleIsRejected = {
    expr = canValidate "mac-mini" (
      validConfig // {
        meta = builtins.removeAttrs validConfig.meta [ "role" ];
      }
    );
    expected = false;
  };

  testInvalidPlatformIsRejected = {
    expr = canValidate "mac-mini" (lib.recursiveUpdate validConfig {
      meta.platform = "nixos";
    });
    expected = false;
  };

  testMissingOperatingSystemIsRejected = {
    expr = canValidate "mac-mini" (
      validConfig // {
        meta = builtins.removeAttrs validConfig.meta [ "os" ];
      }
    );
    expected = false;
  };

  testInvalidOperatingSystemIsRejected = {
    expr = canValidate "mac-mini" (lib.recursiveUpdate validConfig {
      meta.os = "macos";
    });
    expected = false;
  };

  testMissingEnvironmentIsRejected = {
    expr = canValidate "mac-mini" (
      validConfig // {
        meta = builtins.removeAttrs validConfig.meta [ "environment" ];
      }
    );
    expected = false;
  };

  testInvalidEnvironmentIsRejected = {
    expr = canValidate "mac-mini" (lib.recursiveUpdate validConfig {
      meta.environment = "container";
    });
    expected = false;
  };

  testDarwinRejectsWslEnvironment = {
    expr = canValidate "mac-mini" (lib.recursiveUpdate validConfig {
      meta.environment = "wsl";
    });
    expected = false;
  };

  testDarwinPlatformRejectsLinuxOperatingSystem = {
    expr = canValidate "mac-mini" (lib.recursiveUpdate validConfig {
      meta.os = "ubuntu";
    });
    expected = false;
  };

  testInvalidRoleIsRejected = {
    expr = canValidate "mac-mini" (lib.recursiveUpdate validConfig {
      meta.role = "workstation";
    });
    expected = false;
  };

  testHomeManagerPlatformRequiresLinux = {
    expr = canValidate "ubuntu-desktop" (lib.recursiveUpdate validConfig {
      meta.platform = "home-manager";
    });
    expected = false;
  };

  testHomeManagerPlatformAcceptsUbuntu = {
    expr = canValidate "ubuntu-desktop" (lib.recursiveUpdate validConfig {
      meta = {
        system = "x86_64-linux";
        platform = "home-manager";
        os = "ubuntu";
        environment = "native";
        role = "server";
      };
    });
    expected = true;
  };

  testWslEnvironmentAcceptsUbuntu = {
    expr = canValidate "ubuntu-wsl" (lib.recursiveUpdate validConfig {
      meta = {
        system = "x86_64-linux";
        platform = "home-manager";
        os = "ubuntu";
        environment = "wsl";
        role = "desktop";
      };
    });
    expected = true;
  };

  testWslEnvironmentRejectsRaspberryPiOs = {
    expr = canValidate "rpi-wsl" (lib.recursiveUpdate validConfig {
      meta = {
        system = "aarch64-linux";
        platform = "home-manager";
        os = "raspberry-pi-os";
        environment = "wsl";
        role = "server";
      };
    });
    expected = false;
  };

  testRepositoryProvidesFiveHosts = {
    expr = builtins.attrNames (import ../../hosts);
    expected = [
      "mac-mini"
      "macbook-air"
      "raspberry-pi-5"
      "ubuntu-desktop"
      "ubuntu-wsl"
    ];
  };
}
