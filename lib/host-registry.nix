{
  # attrset 形式の設定を持つツール（boolean ツールとは別に検証が必要）
  managedTools = [ "ghostty" "p10k" "starship" "tmux" "zed" ];

  builders = [
    "nix-darwin"
    "home-manager"
  ];

  operatingSystems = {
    macos = {
      builder = "nix-darwin";
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      environments = [ "native" ];
      homeModule = ../modules/home/platforms/darwin/default.nix;
    };

    ubuntu = {
      builder = "home-manager";
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      environments = [
        "native"
        "wsl"
      ];
      homeModule = ../modules/home/platforms/ubuntu/default.nix;
    };

    raspberry-pi-os = {
      builder = "home-manager";
      systems = [ "aarch64-linux" ];
      environments = [ "native" ];
      homeModule = ../modules/home/platforms/raspberry-pi-os/default.nix;
    };
  };

  environments = {
    native.homeModule = ../modules/home/environments/native/default.nix;
    wsl.homeModule = ../modules/home/environments/wsl/default.nix;
  };

  roles = {
    desktop = {
      homeModule = ../modules/home/roles/desktop.nix;
      darwinModule = ../modules/system/darwin/roles/desktop.nix;
    };
    laptop = {
      homeModule = ../modules/home/roles/laptop.nix;
      darwinModule = ../modules/system/darwin/roles/laptop.nix;
    };
    server = {
      homeModule = ../modules/home/roles/server.nix;
      darwinModule = ../modules/system/darwin/roles/server.nix;
    };
  };
}
