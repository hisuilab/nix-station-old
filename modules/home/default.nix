{ lib, homeManager, ... }:

let
  homeModules =
    lib.optional (homeManager.git or false) ./git/default.nix
    ++ lib.optional (homeManager.zsh or false) ../../packages/zsh/default.nix;
in
{
  imports = homeModules;

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
  xdg.enable = true;
}
