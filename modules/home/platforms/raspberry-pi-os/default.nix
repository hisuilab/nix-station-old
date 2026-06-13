{ pkgs, ... }:

{
  home.packages = [ pkgs.docker-client ];

  # OSのブート、ネットワーク、systemdシステムサービスは管理対象外
}
