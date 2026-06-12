{ config, ... }:

{
  programs = {
    bat.enable = true;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    eza = {
      enable = true;
      enableZshIntegration = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      history = {
        path = "${config.xdg.dataHome}/zsh/history";
        save = 10000;
        size = 10000;
      };

      shellAliases = {
        ls = "eza";
        ll = "eza -lh --git";
        la = "eza -lah --git";
        tree = "eza --tree --icons";
      };
    };
  };
}
