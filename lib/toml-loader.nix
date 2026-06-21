# Reads a TOML Host Template and normalizes it to a raw hostConfig attrset
# compatible with validateHostConfig (called by flake.nix).
#
# Transformations applied:
# - home_manager.cli_tools  → homeManager.cliTools
# - home_manager.<t>.config_file → homeManager.<t>.configFile (string → Nix path)
# - darwin.homebrew.brew_bundle  → darwin.homebrew.brewBundle
#
# Temporary: injects userProfile.name = "guest" until Instance separation is
# implemented (issue-44 Decision #1-3).
{ tomlFile }:

let
  registry = import ./host-registry.nix;

  # Repo root: used to resolve config_file strings to absolute Nix paths
  frameworkRoot = ./..;

  raw = builtins.fromTOML (builtins.readFile tomlFile);

  resolveConfigFile = str: frameworkRoot + "/${str}";

  # Normalize home_manager section: snake_case → camelCase, config_file → Nix path
  normalizeHomeManager = hm:
    let
      managedTools = registry.managedTools;
      boolAttrs =
        (if hm ? cli_tools then { cliTools = hm.cli_tools; } else { })
        // (if hm ? gh then { gh = hm.gh; } else { })
        // (if hm ? git then { git = hm.git; } else { })
        // (if hm ? zsh then { zsh = hm.zsh; } else { });
      managedAttrs = builtins.listToAttrs (
        builtins.concatMap
          (name:
            if builtins.hasAttr name hm then
              let cfg = hm.${name}; in
              [{
                inherit name;
                value = {
                  enable = cfg.enable or false;
                } // (if cfg ? config_file then {
                  configFile = resolveConfigFile cfg.config_file;
                } else { });
              }]
            else [ ]
          )
          managedTools
      );
    in
    boolAttrs // managedAttrs;

  # Normalize darwin.homebrew: brew_bundle → brewBundle
  normalizeHomebrew = hb: {
    enable = hb.enable or false;
    install = hb.install or false;
    brewBundle = hb.brew_bundle or false;
  };

  rawDarwin = raw.darwin or { };
in
{
  meta = raw.meta or { };
  homeManager = normalizeHomeManager (raw.home_manager or { });

  # Temporary placeholder until Instance separation is complete (issue-44 Decision #1-3).
  # Instance (~/. config/nix-station/instance.toml) will own userProfile selection.
  userProfile.name = "guest";

} // (if rawDarwin != { } then {
  darwin = rawDarwin // {
    homebrew = normalizeHomebrew (rawDarwin.homebrew or { });
  };
} else { })
