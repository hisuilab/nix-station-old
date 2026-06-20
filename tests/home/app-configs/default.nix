{ pkgs }:

let
  lib = pkgs.lib;
  homeManager = {
    ghostty = {
      enable = true;
      configFile = ../../../modules/home/ghostty/config;
    };
    p10k = {
      enable = true;
      configFile = ../../../modules/home/p10k/p10k.zsh;
    };
    zed = {
      enable = true;
      configFile = ../../../modules/home/zed/settings.json;
    };
    zsh = true;
  };
  hostConfig.meta = {
    os = "macos";
    environment = "native";
    role = "laptop";
  };
  selectedModules = (import ../../../modules/home/default.nix {
    inherit homeManager hostConfig lib;
  }).imports;
  ghosttyModule = import ../../../modules/home/ghostty/default.nix {
    inherit homeManager lib;
  };
  p10kModule = import ../../../modules/home/p10k/default.nix {
    config.home.homeDirectory = "/Users/test";
    inherit homeManager lib pkgs;
  };
  p10kDisabledModule = import ../../../modules/home/p10k/default.nix {
    config.home.homeDirectory = "/Users/test";
    inherit lib pkgs;
    homeManager.p10k = {
      enable = true;
      configFile = null;
    };
  };
  zedModule = import ../../../modules/home/zed/default.nix {
    inherit homeManager lib;
  };
in
lib.runTests {
  testAppConfigFlagsSelectModules = {
    expr = map
      (module: builtins.elem module selectedModules)
      [
        ../../../modules/home/ghostty/default.nix
        ../../../modules/home/p10k/default.nix
        ../../../modules/home/zed/default.nix
      ];
    expected = [ true true true ];
  };

  testGhosttyConfigHasManagedSource = {
    expr = ghosttyModule.xdg.configFile."ghostty/config".source;
    expected = ../../../modules/home/ghostty/config;
  };

  testP10kConfigHasManagedSource = {
    expr = {
      init = lib.hasInfix
        ''source "/Users/test/.p10k.zsh"''
        p10kModule.programs.zsh.initContent;
      package = map (package: package.pname) p10kModule.home.packages;
      source = p10kModule.home.file.".p10k.zsh".source;
      theme = lib.hasInfix
        "/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
        p10kModule.programs.zsh.initContent;
    };
    expected = {
      init = true;
      package = [ "powerlevel10k" ];
      source = ../../../modules/home/p10k/p10k.zsh;
      theme = true;
    };
  };

  testP10kConfigFileCanBeDisabled = {
    expr = {
      config = lib.hasInfix
        ".p10k.zsh"
        p10kDisabledModule.programs.zsh.initContent;
      package = map (package: package.pname) p10kDisabledModule.home.packages;
      source = p10kDisabledModule.home ? file;
      theme = lib.hasInfix
        "/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
        p10kDisabledModule.programs.zsh.initContent;
    };
    expected = {
      config = false;
      package = [ "powerlevel10k" ];
      source = false;
      theme = true;
    };
  };

  testZedConfigHasManagedSource = {
    expr = zedModule.xdg.configFile."zed/settings.json".source;
    expected = ../../../modules/home/zed/settings.json;
  };

}
