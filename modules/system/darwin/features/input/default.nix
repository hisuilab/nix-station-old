{ ... }:

{
  # 起動音を無効化する（nvram StartupMute=%01 に相当）
  system.startup.chime = false;

  system.defaults = {
    CustomUserPreferences.NSGlobalDomain."NSAutomaticTextCompletionEnabled" = false;
    # ライブ変換を無効化する。NSGlobalDomain とは別ドメインのため CustomUserPreferences で設定する
    # ベースドメインと RomajiTyping の両方を無効化しないと片方が有効のまま残る
    CustomUserPreferences."com.apple.inputmethod.Kotoeri"."JIMPrefLiveConversionKey" = false;
    CustomUserPreferences."com.apple.inputmethod.Kotoeri.RomajiTyping"."JIMPrefLiveConversionKey" = false;
    NSGlobalDomain."com.apple.trackpad.scaling" = 3.0;
    CustomUserPreferences.NSGlobalDomain."com.apple.mouse.scaling" = 3.0;
    hitoolbox.AppleFnUsageType = "Do Nothing";

    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
    };
  };
}
