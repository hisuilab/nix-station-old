{ pkgs }:

let
  lib = pkgs.lib;
  module = import ../../../modules/home/zsh/default.nix {
    config.xdg.dataHome = "/Users/test/.local/share";
  };
  homeManager = {
    cliTools = false;
    git = false;
    zsh = true;
  };
  hostConfig.meta = {
    os = "darwin";
    environment = "native";
    role = "desktop";
  };
  selectedModules = (import ../../../modules/home/default.nix {
    inherit homeManager hostConfig lib;
  }).imports;
in
lib.runTests {
  testZshFlagSelectsModule = {
    expr = builtins.elem ../../../modules/home/zsh/default.nix selectedModules;
    expected = true;
  };

  testDisabledGitIsNotSelected = {
    expr = builtins.elem ../../../modules/home/git/default.nix selectedModules;
    expected = false;
  };

  testZshIsEnabled = {
    expr = module.programs.zsh.enable;
    expected = true;
  };

  testZshCompletionIsEnabled = {
    expr = module.programs.zsh.enableCompletion;
    expected = true;
  };

  testZshSyntaxHighlightingIsEnabled = {
    expr = module.programs.zsh.syntaxHighlighting.enable;
    expected = true;
  };

  testZshAutosuggestionIsEnabled = {
    expr = module.programs.zsh.autosuggestion.enable;
    expected = true;
  };

  testZshHistoryIsConfigured = {
    expr = module.programs.zsh.history;
    expected = {
      path = "/Users/test/.local/share/zsh/history";
      save = 10000;
      size = 10000;
    };
  };

}
