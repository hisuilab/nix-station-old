{ hostConfig, lib, homeManager, ... }:

let
  # ツール追加時は名前とモジュールの対応だけを追記
  toolModules = {
    git = ./git/default.nix;
    zsh = ./zsh/default.nix;
  };

  # OS固有のHome Manager設定
  platformModules = {
    darwin = ./platforms/darwin/default.nix;
    ubuntu = ./platforms/ubuntu/default.nix;
    raspberry-pi-os = ./platforms/raspberry-pi-os/default.nix;
  };

  # native・WSLなど実行環境固有のHome Manager設定
  environmentModules = {
    native = ./environments/native/default.nix;
    wsl = ./environments/wsl/default.nix;
  };

  unknownTools = builtins.filter
    (name: !(builtins.hasAttr name toolModules))
    (builtins.attrNames homeManager);

  platformModule =
    if builtins.hasAttr hostConfig.meta.os platformModules then
      platformModules.${hostConfig.meta.os}
    else
      throw "unsupported Home Manager operating system: ${hostConfig.meta.os}";

  environmentModule =
    if builtins.hasAttr hostConfig.meta.environment environmentModules then
      environmentModules.${hostConfig.meta.environment}
    else
      throw "unsupported Home Manager environment: ${hostConfig.meta.environment}";

  roleModule =
    if hostConfig.meta.role == "desktop" then
      ./roles/desktop.nix
    else if hostConfig.meta.role == "laptop" then
      ./roles/laptop.nix
    else if hostConfig.meta.role == "server" then
      ./roles/server.nix
    else
      throw "unsupported Home Manager host role: ${hostConfig.meta.role}";

  enabledToolModules = builtins.concatMap
    (name: lib.optional (homeManager.${name} or false) toolModules.${name})
    (builtins.attrNames toolModules);
in
{
  imports =
    if unknownTools == [ ] then
      [ platformModule environmentModule roleModule ] ++ enabledToolModules
    else
      throw "unsupported Home Manager tools: ${builtins.concatStringsSep ", " unknownTools}";

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
