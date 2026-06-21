{}:

let
  registry = import ./host-registry.nix;

  isNonEmptyString = value:
    builtins.isString value && value != "";

  validateBooleanAttrs = hostId: fieldName: values:
    if !builtins.isAttrs values then
      throw "host '${hostId}': ${fieldName} must be an attribute set"
    else if builtins.all builtins.isBool (builtins.attrValues values) then
      values
    else
      throw "host '${hostId}': every ${fieldName} value must be a boolean";

  validateManagedToolConfig = hostId: name: value:
    let
      allowedKeys = [ "configFile" "enable" ];
      unknownKeys = builtins.filter
        (key: !(builtins.elem key allowedKeys))
        (builtins.attrNames value);
      enable = value.enable or false;
      configFile = value.configFile or null;
    in
    if !builtins.isAttrs value then
      throw "host '${hostId}': homeManager.${name} must be an attribute set"
    else if unknownKeys != [ ] then
      throw "host '${hostId}': unsupported homeManager.${name} settings"
    else if !builtins.isBool enable then
      throw "host '${hostId}': homeManager.${name}.enable must be a boolean"
    else if configFile != null && !builtins.isPath configFile then
      throw "host '${hostId}': homeManager.${name}.configFile must be a path or null"
    else
      {
        inherit configFile enable;
      };

  hasDarwinSettings = config:
    let
      darwin = config.darwin or { };
    in
    (darwin.features or { }) != { }
    || (darwin.homebrew or { }) != { }
    || builtins.removeAttrs darwin [ "features" "homebrew" ] != { };

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
    else if !(config.meta ? builder)
      || !(builtins.elem config.meta.builder registry.builders) then
      throw "host '${hostId}': unsupported meta.builder '${config.meta.builder or "<missing>"}'"
    else if !(config.meta ? os)
      || !(builtins.hasAttr config.meta.os registry.operatingSystems) then
      throw "host '${hostId}': unsupported meta.os '${config.meta.os or "<missing>"}'"
    else if !(config.meta ? environment)
      || !(builtins.hasAttr config.meta.environment registry.environments) then
      throw "host '${hostId}': unsupported meta.environment '${config.meta.environment or "<missing>"}'"
    else if registry.operatingSystems.${config.meta.os}.builder != config.meta.builder then
      throw "host '${hostId}': meta.os '${config.meta.os}' requires meta.builder = '${registry.operatingSystems.${config.meta.os}.builder}'"
    else if !(builtins.elem config.meta.system registry.operatingSystems.${config.meta.os}.systems) then
      throw "host '${hostId}': meta.system '${config.meta.system}' is not supported by meta.os '${config.meta.os}'"
    else if !(builtins.elem config.meta.environment registry.operatingSystems.${config.meta.os}.environments) then
      throw "host '${hostId}': meta.environment '${config.meta.environment}' is not supported by meta.os '${config.meta.os}'"
    else if !(config ? userProfile) || !builtins.isAttrs config.userProfile then
      throw "host '${hostId}': userProfile must be an attribute set"
    else if !(config.userProfile ? name) || !isNonEmptyString config.userProfile.name then
      throw "host '${hostId}': userProfile.name must be a non-empty string"
    else if config ? darwin && !builtins.isAttrs config.darwin then
      throw "host '${hostId}': darwin must be an attribute set"
    else if config.meta.builder != "nix-darwin"
      && config ? darwin
      && hasDarwinSettings config then
      throw "host '${hostId}': darwin settings are only valid for meta.builder = 'nix-darwin'"
    else if (config.darwin or { }) ? homebrew
      && !builtins.isAttrs config.darwin.homebrew then
      throw "host '${hostId}': darwin.homebrew must be an attribute set"
    else if (config.darwin.homebrew or { }) ? enable
      && !builtins.isBool config.darwin.homebrew.enable then
      throw "host '${hostId}': darwin.homebrew.enable must be a boolean"
    else if (config.darwin.homebrew or { }) ? install
      && !builtins.isBool config.darwin.homebrew.install then
      throw "host '${hostId}': darwin.homebrew.install must be a boolean"
    else if (config.darwin.homebrew or { }) ? brewBundle
      && !builtins.isBool config.darwin.homebrew.brewBundle then
      throw "host '${hostId}': darwin.homebrew.brewBundle must be a boolean"
    else
      let
        rawHomeManager = config.homeManager or { };
        managedTools = registry.managedTools;
        booleanHomeManager = validateBooleanAttrs
          hostId
          "homeManager"
          (builtins.removeAttrs rawHomeManager managedTools);
        homeManager = booleanHomeManager // builtins.listToAttrs (
          builtins.concatMap
            (name:
              if builtins.hasAttr name rawHomeManager then [{
                inherit name;
                value = validateManagedToolConfig hostId name rawHomeManager.${name};
              }] else [ ])
            managedTools
        );
        darwinFeatures = validateBooleanAttrs
          hostId
          "darwin.features"
          (config.darwin.features or { });
      in
      if (homeManager.p10k.enable or false) && !(homeManager.zsh or false) then
        throw "host '${hostId}': homeManager.p10k.enable requires homeManager.zsh = true"
      else
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
