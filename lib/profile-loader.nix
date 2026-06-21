# Reads a TOML User Profile and normalizes it to a userProfile attrset
# compatible with validateUserProfile (user-profiles/default.nix).
#
# Transformations applied:
# - git.user_name  → git.userName
# - git.user_email → git.userEmail
{ profileFile }:

let
  raw = builtins.fromTOML (builtins.readFile profileFile);

  requireString = field: value:
    if !builtins.isString value || value == "" then
      throw "profile: ${field} must be a non-empty string"
    else
      value;

  rawGit = raw.git or { };
  userName = requireString "git.user_name" (rawGit.user_name or "");
  userEmail = requireString "git.user_email" (rawGit.user_email or "");
  username = requireString "username" (raw.username or "");
in
{
  inherit username;
  description = raw.description or null;
  git = {
    inherit userName userEmail;
  };
}
