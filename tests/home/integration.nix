{ home-manager, nixpkgs, system }:

let
  userProfiles = import ../../user-profiles { };
  userProfile = userProfiles.loadUserProfile {
    name = "test";
  };
  homeManager = {
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
    inherit homeManager hostConfig userProfile;
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
