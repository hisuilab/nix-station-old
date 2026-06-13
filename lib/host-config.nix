{ }:

let
  isNonEmptyString = value:
    builtins.isString value && value != "";

  validateHostConfig =
    { config
    , hostId
    ,
    }:
    if !isNonEmptyString hostId
      || builtins.match "[a-z0-9]+(-[a-z0-9]+)*" hostId == null then
      throw "host ID must use lowercase kebab-case"
    else if !builtins.isAttrs config then
      throw "host '${hostId}': config must be an attribute set"
    else if !(config ? meta) || !builtins.isAttrs config.meta then
      throw "host '${hostId}': meta must be an attribute set"
    else if config.meta ? hostname && !isNonEmptyString config.meta.hostname then
      throw "host '${hostId}': meta.hostname must be a non-empty string when defined"
    else if !(config.meta ? system) || !isNonEmptyString config.meta.system then
      throw "host '${hostId}': meta.system must be a non-empty string"
    else if !(config.meta ? platform)
      || !(builtins.elem config.meta.platform [ "darwin" "home-manager" ]) then
      throw "host '${hostId}': meta.platform must be 'darwin' or 'home-manager'"
    else if !(config.meta ? role)
      || !(builtins.elem config.meta.role [ "desktop" "laptop" "server" ]) then
      throw "host '${hostId}': meta.role must be 'desktop', 'laptop', or 'server'"
    else if config.meta.platform == "darwin"
      && builtins.match ".*-darwin" config.meta.system == null then
      throw "host '${hostId}': darwin platform requires a Darwin system"
    else if config.meta.platform == "home-manager"
      && builtins.match ".*-linux" config.meta.system == null then
      throw "host '${hostId}': home-manager platform currently requires a Linux system"
    else if !(config ? userProfile) || !builtins.isAttrs config.userProfile then
      throw "host '${hostId}': userProfile must be an attribute set"
    else if !(config.userProfile ? name) || !isNonEmptyString config.userProfile.name then
      throw "host '${hostId}': userProfile.name must be a non-empty string"
    else if !(config ? homeManager) || !builtins.isAttrs config.homeManager then
      throw "host '${hostId}': homeManager must be an attribute set"
    else if !(config.homeManager ? git) || !builtins.isBool config.homeManager.git then
      throw "host '${hostId}': homeManager.git must be a boolean"
    else if !(config.homeManager ? zsh) || !builtins.isBool config.homeManager.zsh then
      throw "host '${hostId}': homeManager.zsh must be a boolean"
    else
      config // {
        meta = config.meta // {
          hostname = config.meta.hostname or hostId;
        };
      };
in
{
  inherit validateHostConfig;
}
