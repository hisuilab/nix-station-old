{ pkgs }:

let
  lib = pkgs.lib;

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

  testUnknownFeatureIsRejected = {
    expr = (builtins.tryEval (builtins.deepSeq
      (selectedModules { unknown = true; })
      true)).success;
    expected = false;
  };
}
