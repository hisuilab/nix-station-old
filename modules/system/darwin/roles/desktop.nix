{ hostConfig, ... }:

{
  nixStation.hostRole = "desktop";
  networking.hostName = hostConfig.meta.hostname;
}
