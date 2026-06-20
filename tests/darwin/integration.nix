{ mkDarwinConfiguration
, userProfile
, lib
,
}:

let
  hostConfigLib = import ../../lib/host-config.nix { };
  system = "aarch64-darwin";

  # extraConfig を validation 前にマージすることで darwin.homebrew などを検証に通す
  makeHostConfigWith = hostId: role: homeManager: extraConfig:
    hostConfigLib.validateHostConfig {
      inherit hostId;
      config = {
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
      } // extraConfig;
    };

  makeHostConfig = hostId: role: homeManager:
    makeHostConfigWith hostId role homeManager { };

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
    hostConfig = makeHostConfigWith "macos-homebrew-test" "desktop"
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
    hostConfig = makeHostConfigWith "macos-existing-homebrew-test" "laptop"
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
        testRole = { expr = disabledHome.nixStation.homeRole; expected = "server"; };
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

  roleRoutingSystem =
    let
      _ = assertAll "roleRoutingSystem" {
        testServerRole = { expr = enabled.config.nixStation.hostRole; expected = "server"; };
        testLaptopRole = { expr = laptop.config.nixStation.hostRole; expected = "laptop"; };
        testDesktopRole = { expr = desktop.config.nixStation.hostRole; expected = "desktop"; };
      };
    in
    desktop.system;

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
