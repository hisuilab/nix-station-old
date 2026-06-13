{ nixpkgsUnstable, pkgs }:

let
  lib = pkgs.lib;
  module = import ../../../modules/home/cli-tools/default.nix {
    inherit nixpkgsUnstable pkgs;
  };
  homeManager = {
    cliTools = true;
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
  testCliToolsFlagSelectsModule = {
    expr = builtins.elem
      ../../../modules/home/cli-tools/default.nix
      selectedModules;
    expected = true;
  };

  testCliToolsAreInstalled = {
    expr = builtins.sort builtins.lessThan
      (map (package: package.pname or package.name) module.home.packages);
    expected = [
      "claude-code"
      "devbox"
      "fd"
      "just"
      "pre-commit"
      "ripgrep"
    ];
  };

  testCliToolProgramsAreEnabled = {
    expr = lib.all (enabled: enabled) [
      module.programs.bat.enable
      module.programs.direnv.enable
      module.programs.eza.enable
      module.programs.fzf.enable
      module.programs.zoxide.enable
    ];
    expected = true;
  };

  testNixDirenvIsEnabled = {
    expr = module.programs.direnv.nix-direnv.enable;
    expected = true;
  };

  testZshIntegrationsAreEnabled = {
    expr = lib.all (enabled: enabled) [
      module.programs.direnv.enableZshIntegration
      module.programs.eza.enableZshIntegration
      module.programs.fzf.enableZshIntegration
      module.programs.zoxide.enableZshIntegration
    ];
    expected = true;
  };

  testToolAliasesAreConfigured = {
    expr = module.programs.zsh.shellAliases;
    expected = {
      ls = "eza";
      ll = "eza -lh --git";
      la = "eza -lah --git";
      tree = "eza --tree --icons";
    };
  };
}
