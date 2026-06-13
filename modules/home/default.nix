{ hostConfig, lib, homeManager, ... }:

let
  registry = import ../../lib/host-registry.nix;

  # ツール追加時は名前とモジュールの対応だけを追記
  toolModules = {
    git = ./git/default.nix;
    zsh = ./zsh/default.nix;
  };

  unknownTools = builtins.filter
    (name: !(builtins.hasAttr name toolModules))
    (builtins.attrNames homeManager);

  platformModule =
    if builtins.hasAttr hostConfig.meta.os registry.operatingSystems then
      registry.operatingSystems.${hostConfig.meta.os}.homeModule
    else
      throw "unsupported Home Manager operating system: ${hostConfig.meta.os}";

  environmentModule =
    if builtins.hasAttr hostConfig.meta.environment registry.environments then
      registry.environments.${hostConfig.meta.environment}.homeModule
    else
      throw "unsupported Home Manager environment: ${hostConfig.meta.environment}";

  roleModule =
    if builtins.hasAttr hostConfig.meta.role registry.roles then
      registry.roles.${hostConfig.meta.role}.homeModule
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
    type = lib.types.enum (builtins.attrNames registry.roles);
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
