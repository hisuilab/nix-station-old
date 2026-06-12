{ hostConfig, ... }:

{
  networking.hostName = hostConfig.meta.hostname;
}
