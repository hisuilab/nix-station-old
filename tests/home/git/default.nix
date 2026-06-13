{ pkgs }:

let
  lib = pkgs.lib;
  userProfile = {
    username = "test";
    git = {
      userName = "Test User";
      userEmail = "test@example.com";
    };
  };
  module = import ../../../modules/home/git/default.nix {
    inherit userProfile;
  };
  homeManager = {
    git = true;
    zsh = false;
  };
  hostConfig.meta.role = "desktop";
  selectedModules = (import ../../../modules/home/default.nix {
    inherit homeManager hostConfig lib;
  }).imports;
in
lib.runTests {
  testGitFlagSelectsModule = {
    expr = builtins.elem ../../../modules/home/git/default.nix selectedModules;
    expected = true;
  };

  testDisabledZshIsNotSelected = {
    expr = builtins.elem ../../../modules/home/zsh/default.nix selectedModules;
    expected = false;
  };

  testGitConfigUsesProfileName = {
    expr = module.programs.git.userName;
    expected = "Test User";
  };

  testGitConfigUsesProfileEmail = {
    expr = module.programs.git.userEmail;
    expected = "test@example.com";
  };

  testGitConfigUsesMainAsDefaultBranch = {
    expr = module.programs.git.extraConfig.init.defaultBranch;
    expected = "main";
  };

  testGitConfigRequiresFastForwardPulls = {
    expr = module.programs.git.extraConfig.pull.ff;
    expected = "only";
  };

  testGitConfigUsesOnlyDeclaredIdentity = {
    expr = module.programs.git.extraConfig.user.useConfigOnly;
    expected = true;
  };
}
