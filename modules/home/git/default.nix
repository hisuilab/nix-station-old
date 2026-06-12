{ userProfile, ... }:

{
  programs.git = {
    enable = true;
    userName = userProfile.git.userName;
    userEmail = userProfile.git.userEmail;

    extraConfig = {
      user.useConfigOnly = true;

      init.defaultBranch = "main";

      pull = {
        ff = "only";
        rebase = false;
      };

      core = {
        eol = "lf";
        quotepath = false;
      };

      fetch.prune = true;
      push.autoSetupRemote = true;
      rebase.autosquash = true;
      rerere.enabled = true;
    };
  };
}
