{ pkgs }:

let
  lib = pkgs.lib;
  homeManager = { };

  selectedModules = os:
    (import ../../../../modules/home/default.nix {
      hostConfig.meta = {
        inherit os;
        environment = "native";
        role = "desktop";
      };
      inherit homeManager lib;
    }).imports;
in
lib.runTests {
  testMacosSelectsDarwinModule = {
    expr = builtins.elem
      ../../../../modules/home/platforms/darwin/default.nix
      (selectedModules "macos");
    expected = true;
  };

  testUbuntuSelectsUbuntuModule = {
    expr = builtins.elem
      ../../../../modules/home/platforms/ubuntu/default.nix
      (selectedModules "ubuntu");
    expected = true;
  };

  testRaspberryPiOsSelectsRaspberryPiOsModule = {
    expr = builtins.elem
      ../../../../modules/home/platforms/raspberry-pi-os/default.nix
      (selectedModules "raspberry-pi-os");
    expected = true;
  };

  testUbuntuDoesNotSelectDarwinModule = {
    expr = builtins.elem
      ../../../../modules/home/platforms/darwin/default.nix
      (selectedModules "ubuntu");
    expected = false;
  };

  testUbuntuInstallsDockerClient = {
    expr = map
      (package: package.pname or package.name)
      (import ../../../../modules/home/platforms/ubuntu/default.nix { inherit pkgs; }).home.packages;
    expected = [ "docker" ];
  };

  testRaspberryPiOsInstallsDockerClient = {
    expr = map
      (package: package.pname or package.name)
      (import ../../../../modules/home/platforms/raspberry-pi-os/default.nix { inherit pkgs; }).home.packages;
    expected = [ "docker" ];
  };

  testUnknownOperatingSystemIsRejected = {
    expr = (builtins.tryEval (
      builtins.deepSeq (selectedModules "unknown") true
    )).success;
    expected = false;
  };
}
