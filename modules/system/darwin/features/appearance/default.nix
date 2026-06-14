{ userProfile, ... }:

{
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleInterfaceStyleSwitchesAutomatically = false;
      AppleShowAllExtensions = true;
    };

    controlcenter.AirDrop = false;
  };

  system.activationScripts.postActivation.text = ''
    user_id="$(id -u ${userProfile.username})"

    launchctl asuser "$user_id" sudo --user=${userProfile.username} \
      defaults delete NSGlobalDomain AppleAccentColor 2>/dev/null || true
    launchctl asuser "$user_id" sudo --user=${userProfile.username} \
      defaults write com.apple.Siri StatusMenuVisible -bool false
    launchctl asuser "$user_id" sudo --user=${userProfile.username} \
      defaults -currentHost write com.apple.Spotlight MenuItemHidden -bool true
    _plist="/Users/${userProfile.username}/Library/Preferences/com.apple.symbolichotkeys.plist"
    launchctl asuser "$user_id" sudo --user=${userProfile.username} \
      /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:64 dict" "$_plist" 2>/dev/null || true
    launchctl asuser "$user_id" sudo --user=${userProfile.username} \
      /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:64:enabled bool false" "$_plist" 2>/dev/null \
      || launchctl asuser "$user_id" sudo --user=${userProfile.username} \
        /usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:64:enabled false" "$_plist"

    launchctl asuser "$user_id" sudo --user=${userProfile.username} \
      killall ControlCenter 2>/dev/null || true
    launchctl asuser "$user_id" sudo --user=${userProfile.username} \
      killall SystemUIServer 2>/dev/null || true
    launchctl asuser "$user_id" sudo --user=${userProfile.username} \
      killall cfprefsd 2>/dev/null || true
  '';
}
