{ mkDarwinConfiguration
, userProfile
,
}:

let
  system = "aarch64-darwin";

  makeHostConfig = hostname: homeManager: {
    meta = {
      inherit hostname system;
    };
    inherit homeManager;
  };

  enabled = mkDarwinConfiguration {
    hostConfig = makeHostConfig "macos-enabled-test" {
      git = true;
      zsh = true;
    };
    inherit userProfile;
  };

  disabled = mkDarwinConfiguration {
    hostConfig = makeHostConfig "macos-disabled-test" {
      git = false;
      zsh = false;
    };
    inherit userProfile;
  };

  gitOnly = mkDarwinConfiguration {
    hostConfig = makeHostConfig "macos-git-test" {
      git = true;
      zsh = false;
    };
    inherit userProfile;
  };

  zshOnly = mkDarwinConfiguration {
    hostConfig = makeHostConfig "macos-zsh-test" {
      git = false;
      zsh = true;
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
    if !(builtins.hasAttr username disabled.config.home-manager.users) then
      disabled.system
    else
      throw "macOS integration test failed: disabled Home Manager user was generated";

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
}
