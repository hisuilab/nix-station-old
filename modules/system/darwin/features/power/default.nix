{ hostConfig, ... }:

{
  # ディスプレイオフ時のスリープ動作をHostごとに明示する（デフォルト: スリープ抑止）
  power.sleep.computer = hostConfig.darwin.power.sleep or "never";
}
