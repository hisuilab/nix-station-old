{ userProfile, ... }:

{
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleInterfaceStyleSwitchesAutomatically = false;
      AppleShowAllExtensions = true;
    };
  };

  system.activationScripts.postActivation.text = ''
    user_id="$(id -u ${userProfile.username})"

    as_user() {
      launchctl asuser "$user_id" sudo --user=${userProfile.username} "$@"
    }

    as_user defaults write com.apple.Siri StatusMenuVisible -bool false
    as_user defaults -currentHost write com.apple.controlcenter Spotlight -int 8

    as_user killall ControlCenter 2>/dev/null || true
    as_user killall SystemUIServer 2>/dev/null || true
  '';
}
