{ hostConfig, ... }:

{
  nixStation.hostRole = "laptop";
  networking.hostName = hostConfig.meta.hostname;
}
