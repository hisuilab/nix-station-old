{
  # mac
  macos-desktop = import ./macos-desktop/config.nix;
  macos-laptop = import ./macos-laptop/config.nix;

  # linux
  raspberry-pi-5 = import ./raspberry-pi-5/config.nix;
  ubuntu-desktop = import ./ubuntu-desktop/config.nix;
  ubuntu-wsl = import ./ubuntu-wsl/config.nix;

  # windowsは管理対象としない
  # - windows-desktop
}
