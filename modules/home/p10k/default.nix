{ config, homeManager, lib, pkgs, ... }:

let
  p10k = homeManager.p10k;
in
{
  home = {
    packages = [ pkgs.zsh-powerlevel10k ];
  } // lib.optionalAttrs (p10k.configFile != null) {
    file.".p10k.zsh".source = p10k.configFile;
    file.".p10k.d".source = ./conf.d;
  };

  programs.zsh.initExtra = ''
    source "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
  '' + lib.optionalString (p10k.configFile != null) ''
    source "${config.home.homeDirectory}/.p10k.zsh"
  '';
}
