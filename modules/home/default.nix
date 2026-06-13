{ hostConfig, lib, homeManager, ... }:

let
  roleModule =
    if hostConfig.meta.role == "desktop" then
      ./roles/desktop.nix
    else if hostConfig.meta.role == "laptop" then
      ./roles/laptop.nix
    else if hostConfig.meta.role == "server" then
      ./roles/server.nix
    else
      throw "unsupported Home Manager host role: ${hostConfig.meta.role}";

  homeModules =
    [ roleModule ]
    ++ lib.optional (homeManager.git or false) ./git/default.nix
    ++ lib.optional (homeManager.zsh or false) ./zsh/default.nix;
in
{
  imports = homeModules;

  options.nixStation.homeRole = lib.mkOption {
    type = lib.types.enum [ "desktop" "laptop" "server" ];
    readOnly = true;
    internal = true;
    description = "Selected Home Manager host role";
  };

  config = {
    home.stateVersion = "24.11";
    programs.home-manager.enable = true;
    xdg.enable = true;
  };
}
