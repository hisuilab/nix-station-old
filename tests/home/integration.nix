{ home-manager, nixpkgs, nixpkgsUnstable, system }:

let
  userProfiles = import ../../user-profiles { };
  userProfile = userProfiles.loadUserProfile {
    name = "test";
  };
  baseHomeManager = {
    cliTools = true;
    git = true;
    zsh = true;
  };
  appConfigHomeManager = {
    zsh = true;
    ghostty = {
      enable = true;
      configFile = ../../modules/home/ghostty/config;
    };
    p10k = {
      enable = true;
      configFile = ../../modules/home/p10k/p10k.zsh;
    };
    starship = {
      enable = true;
      configFile = ../../modules/home/starship/starship.toml;
    };
    tmux = {
      enable = true;
      configFile = ../../modules/home/tmux/tmux.conf;
    };
    zed = {
      enable = true;
      configFile = ../../modules/home/zed/settings.json;
    };
  };
  hostConfig.meta = {
    os = "macos";
    environment = "native";
    role = "desktop";
  };

  mkConfig = homeManager: home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.${system};

    extraSpecialArgs = {
      inherit homeManager hostConfig nixpkgsUnstable userProfile;
    };

    modules = [
      ../../modules/home/default.nix
      {
        home = {
          username = userProfile.username;
          homeDirectory = "/Users/${userProfile.username}";
        };
      }
    ];
  };
in
{
  # 基本ツール（cliTools / git / zsh）の統合評価
  activationPackage = (mkConfig baseHomeManager).activationPackage;

  # managed tools（ghostty / p10k / zed）の統合評価
  appConfigsActivationPackage = (mkConfig appConfigHomeManager).activationPackage;
}
