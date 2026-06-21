{ mkDarwinConfiguration
, userProfile
, lib
,
}:

let
  hostConfigLib = import ../../lib/host-config.nix { };
  system = "aarch64-darwin";

  # extraConfig を validation 前にマージすることで darwin.homebrew などを検証に通す
  makeHostConfigWith = hostId: homeManager: extraConfig:
    hostConfigLib.validateHostConfig {
      inherit hostId;
      config = {
        meta = {
          hostname = hostId;
          inherit system;
          builder = "nix-darwin";
          os = "macos";
          environment = "native";
        };
        userProfile.name = "test";
        inherit homeManager;
      } // extraConfig;
    };

  makeHostConfig = hostId: homeManager:
    makeHostConfigWith hostId homeManager { };

  enabled = mkDarwinConfiguration {
    hostId = "darwin-enabled-test";
    hostConfig = makeHostConfig "macos-enabled-test" {
      git = true;
      zsh = true;
    };
    inherit userProfile;
  };

  disabled = mkDarwinConfiguration {
    hostId = "darwin-disabled-test";
    hostConfig = makeHostConfig "macos-disabled-test" {
      git = false;
      zsh = false;
    };
    inherit userProfile;
  };

  gitOnly = mkDarwinConfiguration {
    hostId = "darwin-git-test";
    hostConfig = makeHostConfig "macos-git-test" {
      git = true;
      zsh = false;
    };
    inherit userProfile;
  };

  zshOnly = mkDarwinConfiguration {
    hostId = "darwin-zsh-test";
    hostConfig = makeHostConfig "macos-zsh-test" {
      git = false;
      zsh = true;
    };
    inherit userProfile;
  };

  homebrewEnabled = mkDarwinConfiguration {
    hostId = "darwin-homebrew-test";
    hostConfig = makeHostConfigWith "macos-homebrew-test"
      {
        git = false;
        zsh = false;
      }
      {
        darwin.homebrew = { enable = true; };
      };
    inherit userProfile;
  };

  existingHomebrew = mkDarwinConfiguration {
    hostId = "darwin-existing-homebrew-test";
    hostConfig = makeHostConfigWith "macos-existing-homebrew-test"
      {
        git = false;
        zsh = false;
      }
      {
        darwin.homebrew = { enable = true; install = false; brewBundle = true; };
      };
    inherit userProfile;
  };

  username = userProfile.username;
  enabledHome = enabled.config.home-manager.users.${username};
  gitOnlyHome = gitOnly.config.home-manager.users.${username};
  zshOnlyHome = zshOnly.config.home-manager.users.${username};

  # 失敗したテストがあれば名前付きエラーで throw する
  assertAll = suiteName: tests:
    let results = lib.runTests tests;
    in if results == [ ]
    then true
    else throw "${suiteName}: ${builtins.toJSON (map (t: t.name) results)}";
in
{
  enabledSystem =
    let
      _ = assertAll "enabledSystem" {
        testHasUser = { expr = builtins.hasAttr username enabled.config.home-manager.users; expected = true; };
        testSystemZsh = { expr = enabled.config.programs.zsh.enable; expected = true; };
        testHomeDir = { expr = enabled.config.users.users.${username}.home; expected = "/Users/${username}"; };
        testShellSet = { expr = enabled.config.users.users.${username}.shell != null; expected = true; };
        testGitEnabled = { expr = enabledHome.programs.git.enable; expected = true; };
        testGitUserName = { expr = enabledHome.programs.git.userName; expected = userProfile.git.userName; };
        testGitEmail = { expr = enabledHome.programs.git.userEmail; expected = userProfile.git.userEmail; };
        testZshEnabled = { expr = enabledHome.programs.zsh.enable; expected = true; };
      };
    in
    enabled.system;

  disabledSystem =
    let
      disabledHome = disabled.config.home-manager.users.${username};
      _ = assertAll "disabledSystem" {
        testHasUser = { expr = builtins.hasAttr username disabled.config.home-manager.users; expected = true; };
        testGitOff = { expr = disabledHome.programs.git.enable; expected = false; };
        testZshOff = { expr = disabledHome.programs.zsh.enable; expected = false; };
        testSystemZsh = { expr = disabled.config.programs.zsh.enable; expected = true; };
        testShellNull = { expr = disabled.config.users.users.${username}.shell == null; expected = true; };
      };
    in
    disabled.system;

  routingSystem =
    let
      _ = assertAll "routingSystem" {
        testGitOnlyGit = { expr = gitOnlyHome.programs.git.enable; expected = true; };
        testGitOnlyZshOff = { expr = gitOnlyHome.programs.zsh.enable; expected = false; };
        testGitOnlySysZsh = { expr = gitOnly.config.programs.zsh.enable; expected = true; };
        testGitOnlyShell = { expr = gitOnly.config.users.users.${username}.shell == null; expected = true; };
        testZshOnlyGitOff = { expr = zshOnlyHome.programs.git.enable; expected = false; };
        testZshOnlyZsh = { expr = zshOnlyHome.programs.zsh.enable; expected = true; };
        testZshOnlySysZsh = { expr = zshOnly.config.programs.zsh.enable; expected = true; };
        testZshOnlyShell = { expr = zshOnly.config.users.users.${username}.shell != null; expected = true; };
      };
    in
    gitOnly.system;

  homebrewSystem =
    let
      _ = assertAll "homebrewSystem" {
        testHbEnabled = { expr = homebrewEnabled.config.nix-homebrew.enable; expected = true; };
        testHbUser = { expr = homebrewEnabled.config.nix-homebrew.user; expected = userProfile.username; };
        testHbPath = { expr = builtins.match "^/opt/homebrew/bin:/opt/homebrew/sbin:.*" homebrewEnabled.config.environment.systemPath != null; expected = true; };
        testExistingOff = { expr = existingHomebrew.config.nix-homebrew.enable; expected = false; };
        testExistingPath = { expr = builtins.match "^/opt/homebrew/bin:/opt/homebrew/sbin:.*" existingHomebrew.config.environment.systemPath != null; expected = true; };
      };
    in
    homebrewEnabled.system;
}
