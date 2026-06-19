{ pkgs }:

let
  lib = pkgs.lib;
  userProfiles = import ../../user-profiles { };
  fixtures = ./fixtures;

  load = name:
    userProfiles.loadUserProfile {
      inherit name;
      profilesDir = fixtures;
    };

  canLoad = name:
    (builtins.tryEval (builtins.deepSeq (load name) true)).success;
in
lib.runTests {
  testGuestProfileLoads = {
    expr = (load "guest").username;
    expected = "guest";
  };

  testRepositoryTestProfileLoads = {
    expr = userProfiles.loadUserProfile {
      name = "test";
    };
    expected = {
      username = "test";
      description = "Repository test user profile";
      git = {
        userName = "test";
        userEmail = "test@example.com";
      };
    };
  };

  testDescriptionMayBeOmitted = {
    expr = (load "without-description").username;
    expected = "without-description";
  };

  testEmptyProfileNameIsRejected = {
    expr = canLoad "";
    expected = false;
  };

  testMissingProfileIsRejected = {
    expr = canLoad "missing";
    expected = false;
  };

  # throw メッセージは builtins.tryEval で内容取得不可のため
  # ソースに案内文が含まれることを readFile で検証する
  testMissingProfileGuidesToInstallScript = {
    expr = lib.hasInfix
      "setup.sh"
      (builtins.readFile ../../user-profiles/default.nix);
    expected = true;
  };

  testEmptyUsernameIsRejected = {
    expr = canLoad "empty-username";
    expected = false;
  };

  testMissingUsernameIsRejected = {
    expr = canLoad "missing-username";
    expected = false;
  };

  testMissingGitUserNameIsRejected = {
    expr = canLoad "missing-git-user-name";
    expected = false;
  };

  testEmptyGitUserNameIsRejected = {
    expr = canLoad "empty-git-user-name";
    expected = false;
  };

  testMissingGitUserEmailIsRejected = {
    expr = canLoad "missing-git-user-email";
    expected = false;
  };

  testEmptyGitUserEmailIsRejected = {
    expr = canLoad "empty-git-user-email";
    expected = false;
  };

  testNonStringDescriptionIsRejected = {
    expr = canLoad "invalid-description";
    expected = false;
  };
}
