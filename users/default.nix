{ ... }:

{
  # ユーザー名からプロファイル（.nix）を動的に引き当てる関数
  importUserProfile = username:
    let
      profilePath = ./. + "/${username}.nix";
    in
    if builtins.pathExists profilePath then
      import profilePath
    else
    builtins.trace
      "warning: user profile '${username}.nix' not found, falling back to guest.nix"
      import ./guest.nix; # ファイルがない場合は安全のためguestにフォールバック
}
