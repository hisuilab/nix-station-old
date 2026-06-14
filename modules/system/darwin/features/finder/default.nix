{ pkgs, userProfile, ... }:

let
  username = userProfile.username;
  homeDirectory = "/Users/${username}";
  mysides = "${pkgs.mysides}/bin/mysides";
in
{
  system.defaults.finder = {
    AppleShowAllFiles = true;
    FXPreferredViewStyle = "Nlsv";
    ShowPathbar = true;
    ShowStatusBar = true;
  };

  system.activationScripts.postActivation.text = ''
    user_id="$(id -u ${username})"

    as_user() {
      launchctl asuser "$user_id" sudo --user=${username} "$@"
    }

    install -d -o ${username} -g staff "${homeDirectory}/Projects"

    as_user ${mysides} remove all
    as_user ${mysides} add Home "file://${homeDirectory}"

    for directory in Desktop Downloads Documents Pictures Music Movies Projects; do
      as_user ${mysides} add "$directory" "file://${homeDirectory}/$directory"
    done

    as_user ${mysides} add Applications "file:///Applications"
    as_user killall Finder 2>/dev/null || true
  '';
}
