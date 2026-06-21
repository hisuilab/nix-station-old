let
  loadToml = tomlFile: import ../lib/toml-loader.nix { inherit tomlFile; };
in
{
  # mac（TOML Host Template）
  macos-desktop = loadToml ./macos-desktop/template.toml;
  macos-laptop = loadToml ./macos-laptop/template.toml;

  # linux（Nix config — TOML移行前）
  raspberry-pi-5 = import ./raspberry-pi-5/config.nix;
  ubuntu-desktop = import ./ubuntu-desktop/config.nix;
  ubuntu-wsl = import ./ubuntu-wsl/config.nix;

  # windowsは管理対象としない
  # - windows-desktop
}
