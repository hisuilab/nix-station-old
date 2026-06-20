{ homeManager, lib, ... }:

{
  programs.starship.enable = true;

  xdg.configFile = lib.optionalAttrs (homeManager.starship.configFile != null) {
    "starship.toml".source = homeManager.starship.configFile;
  };

  programs.zsh.initContent = ''
    export STARSHIP_THEME_DIR="${./theme}"
    source "${./theme.zsh}"
  '';
}
