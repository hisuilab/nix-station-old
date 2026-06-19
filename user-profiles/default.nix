{ ... }:

let
  validateProfileName = name:
    if !builtins.isString name then
      throw "config field 'userProfile.name' must be a string"
    else if name == "" then
      throw "config field 'userProfile.name' must not be empty"
    else
      name;

  requireNonEmptyString = profileName: fieldName: value:
    if !builtins.isString value then
      throw "user profile '${profileName}.nix' field '${fieldName}' must be a string"
    else if value == "" then
      throw "user profile '${profileName}.nix' field '${fieldName}' must not be empty"
    else
      value;

  validateUserProfile = profileName: profile:
    if !builtins.isAttrs profile then
      throw "user profile '${profileName}.nix' must be an attribute set"
    else
      let
        username =
          if profile ? username then
            requireNonEmptyString profileName "username" profile.username
          else
            throw "user profile '${profileName}.nix' is missing required field 'username'";
        git =
          if !(profile ? git) then
            throw "user profile '${profileName}.nix' is missing required field 'git'"
          else if !builtins.isAttrs profile.git then
            throw "user profile '${profileName}.nix' field 'git' must be an attribute set"
          else
            profile.git;
        gitUserName =
          if git ? userName then
            requireNonEmptyString profileName "git.userName" git.userName
          else
            throw "user profile '${profileName}.nix' is missing required field 'git.userName'";
        gitUserEmail =
          if git ? userEmail then
            requireNonEmptyString profileName "git.userEmail" git.userEmail
          else
            throw "user profile '${profileName}.nix' is missing required field 'git.userEmail'";
        description =
          if !(profile ? description) then
            null
          else if !builtins.isString profile.description then
            throw "user profile '${profileName}.nix' field 'description' must be a string"
          else
            profile.description;
      in
      builtins.deepSeq
        [ username gitUserName gitUserEmail description ]
        profile;

  loadUserProfile =
    { name
    , profilesDir ? ./.
    ,
    }:
    let
      profileName = validateProfileName name;
      profilePath = profilesDir + "/${profileName}.nix";
    in
    if !builtins.pathExists profilePath then
      throw ''
        user profile '${profileName}.nix' does not exist.

        修正手順:
          1. ユーザープロファイルを作成する
             cp user-profiles/guest.nix user-profiles/${profileName}.nix
             # username / git.userName / git.userEmail を編集

          または setup.sh を使うと対話形式でセットアップできます:
             bash setup.sh <host-id>
      ''
    else
      validateUserProfile profileName (import profilePath);
in
{
  inherit loadUserProfile;
}
