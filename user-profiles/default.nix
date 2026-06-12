{ ... }:

{
  # プロファイル名から user-profiles/<profile>.nix を動的に引き当てる。
  importUserProfile = profile:
    let
      profilePath = ./. + "/${profile}.nix";
    in
    if builtins.pathExists profilePath then
      import profilePath
    else
    builtins.trace
      "warning: user profile '${profile}.nix' not found, falling back to guest.nix"
      import ./guest.nix;
}
