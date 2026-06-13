{ mkDarwinConfiguration
, userProfile
,
}:

let
  system = "aarch64-darwin";

  makeHostConfig = hostId: role: homeManager: {
    meta = {
      hostname = hostId;
      inherit system;
      platform = "darwin";
      os = "darwin";
      environment = "native";
      inherit role;
    };
    userProfile.name = "test";
    inherit homeManager;
  };

  enabled = mkDarwinConfiguration {
    hostId = "darwin-enabled-test";
    hostConfig = makeHostConfig "macos-enabled-test" "server" {
      git = true;
      zsh = true;
    };
    inherit userProfile;
  };

  disabled = mkDarwinConfiguration {
    hostId = "darwin-disabled-test";
    hostConfig = makeHostConfig "macos-disabled-test" "server" {
      git = false;
      zsh = false;
    };
    inherit userProfile;
  };

  gitOnly = mkDarwinConfiguration {
    hostId = "darwin-git-test";
    hostConfig = makeHostConfig "macos-git-test" "server" {
      git = true;
      zsh = false;
    };
    inherit userProfile;
  };

  zshOnly = mkDarwinConfiguration {
    hostId = "darwin-zsh-test";
    hostConfig = makeHostConfig "macos-zsh-test" "server" {
      git = false;
      zsh = true;
    };
    inherit userProfile;
  };

  laptop = mkDarwinConfiguration {
    hostId = "darwin-laptop-test";
    hostConfig = makeHostConfig "macos-laptop-test" "laptop" {
      git = false;
      zsh = false;
    };
    inherit userProfile;
  };

  desktop = mkDarwinConfiguration {
    hostId = "darwin-desktop-test";
    hostConfig = makeHostConfig "macos-desktop-test" "desktop" {
      git = false;
      zsh = false;
    };
    inherit userProfile;
  };

  homebrewEnabled = mkDarwinConfiguration {
    hostId = "darwin-homebrew-test";
    hostConfig = (makeHostConfig "macos-homebrew-test" "desktop" {
      git = false;
      zsh = false;
    }) // {
      darwin.homebrew = {
        enable = true;
        brews = [ "wget" ];
        casks = [ "ghostty" ];
      };
    };
    inherit userProfile;
  };

  username = userProfile.username;
  enabledHome = enabled.config.home-manager.users.${username};
  gitOnlyHome = gitOnly.config.home-manager.users.${username};
  zshOnlyHome = zshOnly.config.home-manager.users.${username};
in
{
  enabledSystem =
    if
      builtins.hasAttr username enabled.config.home-manager.users
      && enabled.config.programs.zsh.enable
      && enabled.config.users.users.${username}.home == "/Users/${username}"
      && enabled.config.users.users.${username}.shell != null
      && enabledHome.programs.git.enable
      && enabledHome.programs.git.userName == userProfile.git.userName
      && enabledHome.programs.git.userEmail == userProfile.git.userEmail
      && enabledHome.programs.zsh.enable
    then
      enabled.system
    else
      throw "macOS integration test failed: enabled Home Manager user or Zsh shell missing";

  disabledSystem =
    let
      disabledHome = disabled.config.home-manager.users.${username};
    in
    if
      builtins.hasAttr username disabled.config.home-manager.users
      && disabledHome.nixStation.homeRole == "server"
      && !disabledHome.programs.git.enable
      && !disabledHome.programs.zsh.enable
      && !disabled.config.programs.zsh.enable
      && disabled.config.users.users.${username}.shell == null
    then
      disabled.system
    else
      throw "macOS integration test failed: base Home Manager user was not generated";

  routingSystem =
    if
      gitOnlyHome.programs.git.enable
      && !gitOnlyHome.programs.zsh.enable
      && !gitOnly.config.programs.zsh.enable
      && gitOnly.config.users.users.${username}.shell == null
      && !zshOnlyHome.programs.git.enable
      && zshOnlyHome.programs.zsh.enable
      && zshOnly.config.programs.zsh.enable
      && zshOnly.config.users.users.${username}.shell != null
    then
      gitOnly.system
    else
      throw "macOS integration test failed: Home Manager flags selected incorrect modules";

  roleRoutingSystem =
    if
      enabled.config.nixStation.hostRole == "server"
      && laptop.config.nixStation.hostRole == "laptop"
      && desktop.config.nixStation.hostRole == "desktop"
    then
      desktop.system
    else
      throw "nix-darwin integration test failed: host role selected incorrect module";

  homebrewSystem =
    if
      homebrewEnabled.config.homebrew.enable
      && map (brew: brew.name) homebrewEnabled.config.homebrew.brews == [ "wget" ]
      && map (cask: cask.name) homebrewEnabled.config.homebrew.casks == [ "ghostty" ]
      && homebrewEnabled.config.homebrew.onActivation.cleanup == "zap"
    then
      homebrewEnabled.system
    else
      throw "nix-darwin integration test failed: Homebrew settings were not applied: ${
        builtins.toJSON {
          enable = homebrewEnabled.config.homebrew.enable;
          brews = homebrewEnabled.config.homebrew.brews;
          casks = homebrewEnabled.config.homebrew.casks;
          cleanup = homebrewEnabled.config.homebrew.onActivation.cleanup;
        }
      }";
}
