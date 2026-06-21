{ pkgs }:

let
  lib = pkgs.lib;
  homeManager = { };

  selectedModules = environment:
    (import ../../../../modules/home/default.nix {
      hostConfig.meta = {
        os = "ubuntu";
        inherit environment;
        role = "desktop";
      };
      inherit homeManager lib;
    }).imports;
in
lib.runTests {
  testNativeSelectsNativeModule = {
    expr = builtins.elem
      ../../../../modules/home/environments/native/default.nix
      (selectedModules "native");
    expected = true;
  };

  testWslSelectsWslModule = {
    expr = builtins.elem
      ../../../../modules/home/environments/wsl/default.nix
      (selectedModules "wsl");
    expected = true;
  };

  testWslDoesNotSelectNativeModule = {
    expr = builtins.elem
      ../../../../modules/home/environments/native/default.nix
      (selectedModules "wsl");
    expected = false;
  };

  testUnknownEnvironmentIsRejected = {
    expr = (builtins.tryEval (
      builtins.deepSeq (selectedModules "unknown") true
    )).success;
    expected = false;
  };

  testWslConfigUsesWslviewBrowser = {
    expr =
      (import ../../../../modules/home/environments/wsl/default.nix { inherit pkgs; }).home.sessionVariables.BROWSER;
    expected = "wslview";
  };
}
