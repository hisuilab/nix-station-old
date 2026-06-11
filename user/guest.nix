{ lib, ... }:

{
  options.userProfile = {
    description = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
  };

  config.userProfile = {
    description = "Generic guest user profile";
  };
}
