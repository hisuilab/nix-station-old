{ pkgs }:

let
  lib = pkgs.lib;
  module = import ../../../modules/home/gh/default.nix { };
  homeManager = {
    gh = true;
  };
  hostConfig.meta = {
    os = "macos";
    environment = "native";
    role = "desktop";
  };
  selectedModules = (import ../../../modules/home/default.nix {
    inherit homeManager hostConfig lib;
  }).imports;
in
lib.runTests {
  testGhFlagSelectsModule = {
    expr = builtins.elem ../../../modules/home/gh/default.nix selectedModules;
    expected = true;
  };

  testGhIsEnabled = {
    expr = module.programs.gh.enable;
    expected = true;
  };

  testGhUsesSshProtocol = {
    expr = module.programs.gh.settings.git_protocol;
    expected = "ssh";
  };
}
