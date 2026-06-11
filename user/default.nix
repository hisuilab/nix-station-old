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
      import ./guest.nix; # ファイルがない場合は安全のためguestにフォールバック
}
