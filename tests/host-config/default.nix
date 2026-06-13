{ pkgs }:

let
  lib = pkgs.lib;
  hostConfigLib = import ../../lib/host-config.nix { };

  validConfig = {
    meta = {
      system = "aarch64-darwin";
      platform = "darwin";
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

  testRepositoryProvidesFourHosts = {
    expr = builtins.attrNames (import ../../hosts);
    expected = [
      "mac-mini"
      "macbook-air"
      "rpi5"
      "ubuntu-desktop"
    ];
  };
}
