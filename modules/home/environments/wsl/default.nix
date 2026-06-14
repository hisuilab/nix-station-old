{ pkgs, ... }:

{
  # WSL固有のユーザー設定の追加先
  home.packages = [
    pkgs.wslu
  ];

  home.sessionVariables = {
    BROWSER = "wslview";
  };
}
