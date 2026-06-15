{ home-manager, nixpkgs, nixpkgsUnstable, system }:

let
  userProfile = (import ../../user-profiles { }).loadUserProfile {
    name = "test";
    profilesDir = ../user-profile;
  };
  homeManager = {
    cliTools = true;
    git = true;
    zsh = true;
  };
  hostConfig.meta = {
    os = "darwin";
    environment = "native";
    role = "desktop";
  };
in
home-manager.lib.homeManagerConfiguration {
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
}
