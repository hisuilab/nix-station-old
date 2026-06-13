{ hostConfig, ... }:

{
  nixStation.hostRole = "server";
  networking.hostName = hostConfig.meta.hostname;
}
