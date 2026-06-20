{ homeManager, lib, pkgs, ... }:

{
  home.packages = [ pkgs.tmux ];

  xdg.configFile = lib.optionalAttrs (homeManager.tmux.configFile != null) {
    "tmux/tmux.conf".source = homeManager.tmux.configFile;
  };

  programs.zsh.shellAliases = {
    t = "tmux new-session -A -s main";
    tn = "tmux new-session";
    tl = "tmux list-sessions";
    ta = "tmux attach";
    tk = "tmux kill-session";
    tka = "tmux kill-server";
  };
}
