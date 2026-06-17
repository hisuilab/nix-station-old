{ hostConfig, ... }:

{
  # デスクトップ・サーバー用途: ディスプレイオフ時もシステムスリープを抑止する
  power.sleep.computer = if hostConfig.meta.role == "laptop" then 10 else "never";
}
