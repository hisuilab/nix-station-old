{}:

let
  isNonEmptyString = value:
    builtins.isString value && value != "";

  validateBooleanAttrs = hostId: fieldName: values:
    if !builtins.isAttrs values then
      throw "host '${hostId}': ${fieldName} must be an attribute set"
    else if builtins.all builtins.isBool (builtins.attrValues values) then
      values
    else
      throw "host '${hostId}': every ${fieldName} value must be a boolean";

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
    else if !(config.meta ? os)
      || !(builtins.elem config.meta.os [ "darwin" "ubuntu" "raspberry-pi-os" ]) then
      throw "host '${hostId}': meta.os must be 'darwin', 'ubuntu', or 'raspberry-pi-os'"
    else if !(config.meta ? environment)
      || !(builtins.elem config.meta.environment [ "native" "wsl" ]) then
      throw "host '${hostId}': meta.environment must be 'native' or 'wsl'"
    else if !(config.meta ? role)
      || !(builtins.elem config.meta.role [ "desktop" "laptop" "server" ]) then
      throw "host '${hostId}': meta.role must be 'desktop', 'laptop', or 'server'"
    else if config.meta.platform == "darwin"
      && builtins.match ".*-darwin" config.meta.system == null then
      throw "host '${hostId}': darwin platform requires a Darwin system"
    else if config.meta.platform == "darwin" && config.meta.os != "darwin" then
      throw "host '${hostId}': darwin platform requires meta.os = 'darwin'"
    else if config.meta.platform == "darwin" && config.meta.environment != "native" then
      throw "host '${hostId}': darwin platform requires meta.environment = 'native'"
    else if config.meta.platform == "home-manager"
      && builtins.match ".*-linux" config.meta.system == null then
      throw "host '${hostId}': home-manager platform currently requires a Linux system"
    else if config.meta.platform == "home-manager" && config.meta.os == "darwin" then
      throw "host '${hostId}': home-manager platform requires a Linux operating system"
    else if config.meta.environment == "wsl" && config.meta.os != "ubuntu" then
      throw "host '${hostId}': wsl environment currently requires meta.os = 'ubuntu'"
    else if !(config ? userProfile) || !builtins.isAttrs config.userProfile then
      throw "host '${hostId}': userProfile must be an attribute set"
    else if !(config.userProfile ? name) || !isNonEmptyString config.userProfile.name then
      throw "host '${hostId}': userProfile.name must be a non-empty string"
    else if config ? darwin && !builtins.isAttrs config.darwin then
      throw "host '${hostId}': darwin must be an attribute set"
    else if (config.darwin or { }) ? homebrew
      && !builtins.isAttrs config.darwin.homebrew then
      throw "host '${hostId}': darwin.homebrew must be an attribute set"
    else if (config.darwin.homebrew or { }) ? enable
      && !builtins.isBool config.darwin.homebrew.enable then
      throw "host '${hostId}': darwin.homebrew.enable must be a boolean"
    else
      let
        homeManager = validateBooleanAttrs
          hostId
          "homeManager"
          (config.homeManager or { });
        darwinFeatures = validateBooleanAttrs
          hostId
          "darwin.features"
          (config.darwin.features or { });
      in
      builtins.deepSeq [ homeManager darwinFeatures ] (
        config // {
          meta = config.meta // {
            hostname = config.meta.hostname or hostId;
          };
          inherit homeManager;
          darwin = (config.darwin or { }) // {
            features = darwinFeatures;
            homebrew = config.darwin.homebrew or { };
          };
        }
      );
in
{
  inherit validateHostConfig;
}
