{ pkgs }:

let
  lib = pkgs.lib;
  homeManager = { };

  selectedModules = os:
    (import ../../../modules/home/default.nix {
      hostConfig.meta = {
        inherit os;
        environment = "native";
        role = "desktop";
      };
      inherit homeManager lib;
    }).imports;
in
lib.runTests {
  testDarwinSelectsDarwinModule = {
    expr = builtins.elem
      ../../../modules/home/platforms/darwin/default.nix
      (selectedModules "darwin");
    expected = true;
  };

  testUbuntuSelectsUbuntuModule = {
    expr = builtins.elem
      ../../../modules/home/platforms/ubuntu/default.nix
      (selectedModules "ubuntu");
    expected = true;
  };

  testRaspberryPiOsSelectsRaspberryPiOsModule = {
    expr = builtins.elem
      ../../../modules/home/platforms/raspberry-pi-os/default.nix
      (selectedModules "raspberry-pi-os");
    expected = true;
  };

  testUbuntuDoesNotSelectDarwinModule = {
    expr = builtins.elem
      ../../../modules/home/platforms/darwin/default.nix
      (selectedModules "ubuntu");
    expected = false;
  };

  testUnknownOperatingSystemIsRejected = {
    expr = (builtins.tryEval (
      builtins.deepSeq (selectedModules "unknown") true
    )).success;
    expected = false;
  };
}
