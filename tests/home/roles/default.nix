{ pkgs }:

let
  lib = pkgs.lib;
  homeManager = {
    git = false;
    zsh = false;
  };

  selectedModules = role:
    (import ../../../modules/home/default.nix {
      hostConfig.meta = {
        os = "darwin";
        environment = "native";
        inherit role;
      };
      inherit homeManager lib;
    }).imports;
in
lib.runTests {
  testDesktopRoleSelectsDesktopModule = {
    expr = builtins.elem
      ../../../modules/home/roles/desktop.nix
      (selectedModules "desktop");
    expected = true;
  };

  testLaptopRoleSelectsLaptopModule = {
    expr = builtins.elem
      ../../../modules/home/roles/laptop.nix
      (selectedModules "laptop");
    expected = true;
  };

  testServerRoleSelectsServerModule = {
    expr = builtins.elem
      ../../../modules/home/roles/server.nix
      (selectedModules "server");
    expected = true;
  };
}
