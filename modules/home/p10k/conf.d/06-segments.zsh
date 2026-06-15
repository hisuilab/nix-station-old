# ============================================================
# command_execution_time: コマンド実行時間
# ============================================================
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=$C_WARNING
# この秒数以上で表示
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
# 小数点以下の桁数 (0=秒単位)
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
# 表示フォーマット
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'

# ============================================================
# background_jobs: バックグラウンドジョブ
# ============================================================
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND=$C_DARK
# ジョブ数を表示しない
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=false

# ============================================================
# direnv: direnv 状態
# ============================================================
typeset -g POWERLEVEL9K_DIRENV_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_DIRENV_BACKGROUND=$C_NEON_PURPLE

# ============================================================
# nordvpn: NordVPN 状態 (Linux)
# ============================================================
typeset -g POWERLEVEL9K_NORDVPN_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_NORDVPN_BACKGROUND=$C_SUCCESS_ALT
# 未接続時は非表示
typeset -g POWERLEVEL9K_NORDVPN_{DISCONNECTED,CONNECTING,DISCONNECTING}_CONTENT_EXPANSION=
typeset -g POWERLEVEL9K_NORDVPN_{DISCONNECTED,CONNECTING,DISCONNECTING}_VISUAL_IDENTIFIER_EXPANSION=

# ============================================================
# ファイルマネージャシェル
# ============================================================
# ranger
typeset -g POWERLEVEL9K_RANGER_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_RANGER_BACKGROUND=$C_DARK

# yazi
typeset -g POWERLEVEL9K_YAZI_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_YAZI_BACKGROUND=$C_DARK

# nnn
typeset -g POWERLEVEL9K_NNN_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_NNN_BACKGROUND=$C_DARK

# lf
typeset -g POWERLEVEL9K_LF_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_LF_BACKGROUND=$C_DARK

# xplr
typeset -g POWERLEVEL9K_XPLR_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_XPLR_BACKGROUND=$C_DARK

# ============================================================
# vim_shell: vim シェル (:sh)
# ============================================================
typeset -g POWERLEVEL9K_VIM_SHELL_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_VIM_SHELL_BACKGROUND=$C_SUCCESS

# ============================================================
# midnight_commander: mc シェル
# ============================================================
typeset -g POWERLEVEL9K_MIDNIGHT_COMMANDER_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_MIDNIGHT_COMMANDER_BACKGROUND=$C_SUCCESS_ALT

# ============================================================
# nix_shell: nix シェル
# ============================================================
typeset -g POWERLEVEL9K_NIX_SHELL_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_NIX_SHELL_BACKGROUND=$C_INDIGO

# ============================================================
# disk_usage: ディスク使用量
# ============================================================
typeset -g POWERLEVEL9K_DISK_USAGE_NORMAL_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_DISK_USAGE_NORMAL_BACKGROUND=$C_SUCCESS
typeset -g POWERLEVEL9K_DISK_USAGE_WARNING_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_DISK_USAGE_WARNING_BACKGROUND=$C_WARNING
typeset -g POWERLEVEL9K_DISK_USAGE_CRITICAL_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_DISK_USAGE_CRITICAL_BACKGROUND=$C_ERROR
# 警告/危険の閾値 (%)
typeset -g POWERLEVEL9K_DISK_USAGE_WARNING_LEVEL=90
typeset -g POWERLEVEL9K_DISK_USAGE_CRITICAL_LEVEL=95
# 警告レベル未満は非表示
typeset -g POWERLEVEL9K_DISK_USAGE_ONLY_WARNING=false

# ============================================================
# vi_mode: vi モード表示
# ============================================================
typeset -g POWERLEVEL9K_VI_MODE_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_VI_COMMAND_MODE_STRING=NORMAL
typeset -g POWERLEVEL9K_VI_MODE_NORMAL_BACKGROUND=$C_SUCCESS
typeset -g POWERLEVEL9K_VI_VISUAL_MODE_STRING=VISUAL
typeset -g POWERLEVEL9K_VI_MODE_VISUAL_BACKGROUND=$C_WARNING
typeset -g POWERLEVEL9K_VI_OVERWRITE_MODE_STRING=OVERTYPE
typeset -g POWERLEVEL9K_VI_MODE_OVERWRITE_BACKGROUND=$C_ERROR
typeset -g POWERLEVEL9K_VI_INSERT_MODE_STRING=
typeset -g POWERLEVEL9K_VI_MODE_INSERT_FOREGROUND=$C_SUCCESS

# ============================================================
# ram: メモリ使用量
# ============================================================
typeset -g POWERLEVEL9K_RAM_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_RAM_BACKGROUND=$C_NEON_PURPLE

# ============================================================
# swap: スワップ使用量
# ============================================================
typeset -g POWERLEVEL9K_SWAP_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_SWAP_BACKGROUND=$C_WARNING

# ============================================================
# load: CPU 負荷
# ============================================================
# 平均負荷の期間 (1, 5, 15 分)
typeset -g POWERLEVEL9K_LOAD_WHICH=5
typeset -g POWERLEVEL9K_LOAD_NORMAL_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_LOAD_NORMAL_BACKGROUND=$C_SUCCESS
typeset -g POWERLEVEL9K_LOAD_WARNING_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_LOAD_WARNING_BACKGROUND=$C_WARNING
typeset -g POWERLEVEL9K_LOAD_CRITICAL_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_LOAD_CRITICAL_BACKGROUND=$C_ERROR

# ============================================================
# todo: todo.txt タスク数
# ============================================================
typeset -g POWERLEVEL9K_TODO_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_TODO_BACKGROUND=$C_INDIGO
# タスクがない場合は非表示
typeset -g POWERLEVEL9K_TODO_HIDE_ZERO_TOTAL=true
typeset -g POWERLEVEL9K_TODO_HIDE_ZERO_FILTERED=false

# ============================================================
# timewarrior: 時間追跡状態
# ============================================================
typeset -g POWERLEVEL9K_TIMEWARRIOR_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_TIMEWARRIOR_BACKGROUND=$C_SUCCESS_ALT
# 24文字超は省略
typeset -g POWERLEVEL9K_TIMEWARRIOR_CONTENT_EXPANSION='${P9K_CONTENT:0:24}${${P9K_CONTENT:24}:+…}'

# ============================================================
# taskwarrior: タスク数
# ============================================================
typeset -g POWERLEVEL9K_TASKWARRIOR_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_TASKWARRIOR_BACKGROUND=$C_SUCCESS_ALT

# ============================================================
# per_directory_history: ディレクトリ別履歴 (OMZ)
# ============================================================
typeset -g POWERLEVEL9K_PER_DIRECTORY_HISTORY_LOCAL_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_PER_DIRECTORY_HISTORY_LOCAL_BACKGROUND=$C_INDIGO
typeset -g POWERLEVEL9K_PER_DIRECTORY_HISTORY_GLOBAL_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_PER_DIRECTORY_HISTORY_GLOBAL_BACKGROUND=$C_SUCCESS_ALT

# ============================================================
# cpu_arch: CPU アーキテクチャ
# ============================================================
typeset -g POWERLEVEL9K_CPU_ARCH_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_CPU_ARCH_BACKGROUND=$C_SUCCESS_ALT

# ============================================================
# context: user@hostname
# ============================================================
# root 時 - ホットピンク
typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND=$C_ERROR
# SSH 接続時 - ネオンパープル
typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_BACKGROUND=$C_NEON_PURPLE
# 通常時
typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND=$C_DARK
# フォーマット
typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE='%n@%m'
typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_TEMPLATE='%n@%m'
typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'
# root/SSH 以外では非表示
typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=

# ============================================================
# public_ip: パブリック IP
# ============================================================
typeset -g POWERLEVEL9K_PUBLIC_IP_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_PUBLIC_IP_BACKGROUND=$C_DARK

# ============================================================
# vpn_ip: VPN 接続状態
# ============================================================
typeset -g POWERLEVEL9K_VPN_IP_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_VPN_IP_BACKGROUND=$C_SUCCESS
# アイコンのみ表示 (IP アドレスは非表示)
typeset -g POWERLEVEL9K_VPN_IP_CONTENT_EXPANSION=
# VPN インターフェース名のパターン
typeset -g POWERLEVEL9K_VPN_IP_INTERFACE='(gpd|wg|(.*tun)|tailscale)[0-9]*|(zt.*)'
# 全インターフェース表示
typeset -g POWERLEVEL9K_VPN_IP_SHOW_ALL=false

# ============================================================
# ip: IP アドレス / 帯域
# ============================================================
typeset -g POWERLEVEL9K_IP_BACKGROUND=$C_SUCCESS_ALT
typeset -g POWERLEVEL9K_IP_FOREGROUND=$C_BLACK
# 表示フォーマット (受信レート 送信レート IP)
typeset -g POWERLEVEL9K_IP_CONTENT_EXPANSION='${P9K_IP_RX_RATE:+⇣$P9K_IP_RX_RATE }${P9K_IP_TX_RATE:+⇡$P9K_IP_TX_RATE }$P9K_IP_IP'
# 対象インターフェース名のパターン
typeset -g POWERLEVEL9K_IP_INTERFACE='[ew].*'

# ============================================================
# proxy: プロキシ設定
# ============================================================
typeset -g POWERLEVEL9K_PROXY_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_PROXY_BACKGROUND=$C_SUCCESS_ALT

# ============================================================
# battery: バッテリー
# ============================================================
# 低残量の閾値 (%)
typeset -g POWERLEVEL9K_BATTERY_LOW_THRESHOLD=20
typeset -g POWERLEVEL9K_BATTERY_LOW_FOREGROUND=$C_ERROR
# 充電中/満充電
typeset -g POWERLEVEL9K_BATTERY_{CHARGING,CHARGED}_FOREGROUND=$C_SUCCESS
# 放電中
typeset -g POWERLEVEL9K_BATTERY_DISCONNECTED_FOREGROUND=$C_WARNING
# バッテリーアイコン (低→高)
typeset -g POWERLEVEL9K_BATTERY_STAGES='\UF008E\UF007A\UF007B\UF007C\UF007D\UF007E\UF007F\UF0080\UF0081\UF0082\UF0079'
# 残り時間を非表示
typeset -g POWERLEVEL9K_BATTERY_VERBOSE=false
typeset -g POWERLEVEL9K_BATTERY_BACKGROUND=$C_DARK

# ============================================================
# wifi: WiFi 速度
# ============================================================
typeset -g POWERLEVEL9K_WIFI_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_WIFI_BACKGROUND=$C_SUCCESS_ALT

# ============================================================
# time: 現在時刻
# ============================================================
typeset -g POWERLEVEL9K_TIME_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_TIME_BACKGROUND=$C_DARK
# 表示フォーマット (HH:MM:SS)
typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
# コマンド実行時に時刻を更新
typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false
