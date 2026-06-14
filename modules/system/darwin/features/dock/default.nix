{ hostConfig, lib, pkgs, userProfile, ... }:

let
  dockApps = [
    "/System/Applications/Apps.app"
    "/Applications/Google Chrome.app"
    "/Applications/Slack.app"
    "/Applications/Discord.app"
    "/System/Applications/Photos.app"
    "/System/Applications/Notes.app"
    "/Applications/Visual Studio Code.app"
    "/Applications/Zed.app"
    "/Applications/Codex.app"
    "/Applications/Ghostty.app"
    "/Applications/Docker.app/Contents/MacOS/Docker Desktop.app"
    "/System/Applications/System Settings.app"
  ];
in
{
  system.defaults.dock = {
    autohide = hostConfig.meta.role == "laptop";
    mru-spaces = false;
    orientation =
      if hostConfig.meta.role == "laptop"
      then "bottom"
      else "left";
    show-recents = false;
    tilesize = 48;
  };

  system.activationScripts.postActivation.text = ''
    user_id="$(id -u ${userProfile.username})"
    dock_plist="/Users/${userProfile.username}/Library/Preferences/com.apple.dock.plist"

    launchctl asuser "$user_id" sudo --user=${userProfile.username} \
      ${pkgs.dockutil}/bin/dockutil --remove all --no-restart "$dock_plist"

    for app in ${lib.escapeShellArgs dockApps}; do
      if [ -e "$app" ]; then
        launchctl asuser "$user_id" sudo --user=${userProfile.username} \
          ${pkgs.dockutil}/bin/dockutil --add "$app" --no-restart "$dock_plist"
      fi
    done

    for handler in public.html http https; do
      launchctl asuser "$user_id" sudo --user=${userProfile.username} \
        ${pkgs.duti}/bin/duti -s com.google.Chrome "$handler" all
    done

    for handler in public.xml public.xhtml xml xhtml; do
      launchctl asuser "$user_id" sudo --user=${userProfile.username} \
        ${pkgs.duti}/bin/duti -s com.microsoft.VSCode "$handler" all
    done

    launchctl asuser "$user_id" sudo --user=${userProfile.username} \
      killall cfprefsd 2>/dev/null || true
    launchctl asuser "$user_id" sudo --user=${userProfile.username} \
      killall Dock 2>/dev/null || true
  '';
}
