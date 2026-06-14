{ pkgs, ... }:

{
  # Docker daemonとユーザー権限はOS側で管理する
  home.packages = [ pkgs.docker-client ];
}
