{ lib, ... }:

{
  # 1. 独自の設定項目（枠組み）を定義する
  options.userProfile = {
    description = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
  };

  # 2. 定義した項目に、実際のデータを流し込む
  config.userProfile = {
    description = "Primary user profile for hisuilab";
  };
}
