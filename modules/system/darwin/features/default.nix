{ hostConfig, lib, ... }:

let
  # 機能追加時は名前とモジュールの対応だけを追記
  featureModules = {
    appearance = ./appearance/default.nix;
    dock = ./dock/default.nix;
    finder = ./finder/default.nix;
    input = ./input/default.nix;
    power = ./power/default.nix;
  };

  enabledFeatures = hostConfig.darwin.features or { };
  unknownFeatures = builtins.filter
    (name: !(builtins.hasAttr name featureModules))
    (builtins.attrNames enabledFeatures);
in
{
  imports =
    if unknownFeatures == [ ] then
      builtins.concatMap
        (name: lib.optional (enabledFeatures.${name} or false) featureModules.${name})
        (builtins.attrNames featureModules)
    else
      throw "unsupported nix-darwin features: ${builtins.concatStringsSep ", " unknownFeatures}";
}
