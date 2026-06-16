# ============================================================
# 左プロンプト要素
# ============================================================
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  # === 1行目 ===
  os_icon                 # OS アイコン
  dir                     # カレントディレクトリ
  vcs                     # Git ステータス
  # === 2行目 ===
  newline                 # 改行
  prompt_char             # プロンプト記号
)

# ============================================================
# 右プロンプト要素
# ============================================================
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  # === 1行目 ===
  status                  # 終了コード
  command_execution_time  # コマンド実行時間
  background_jobs         # バックグラウンドジョブ
  direnv                  # direnv 状態
  asdf                    # asdf バージョン管理
  virtualenv              # Python 仮想環境
  anaconda                # conda 環境
  pyenv                   # Python 環境
  goenv                   # Go 環境
  nodenv                  # Node.js (nodenv)
  nvm                     # Node.js (nvm)
  nodeenv                 # Node.js 環境
  # node_version          # Node.js バージョン
  # go_version            # Go バージョン
  # rust_version          # Rust バージョン
  # dotnet_version        # .NET バージョン
  # php_version           # PHP バージョン
  # laravel_version       # Laravel バージョン
  # java_version          # Java バージョン
  # package               # package.json の name@version
  rbenv                   # Ruby (rbenv)
  rvm                     # Ruby (rvm)
  fvm                     # Flutter (fvm)
  luaenv                  # Lua (luaenv)
  jenv                    # Java (jenv)
  plenv                   # Perl (plenv)
  perlbrew                # Perl (perlbrew)
  phpenv                  # PHP (phpenv)
  scalaenv                # Scala (scalaenv)
  haskell_stack           # Haskell (stack)
  kubecontext             # Kubernetes コンテキスト
  terraform               # Terraform ワークスペース
  # terraform_version     # Terraform バージョン
  aws                     # AWS プロファイル
  aws_eb_env              # AWS Elastic Beanstalk
  azure                   # Azure アカウント
  gcloud                  # Google Cloud
  google_app_cred         # Google 認証情報
  toolbox                 # Toolbox 名
  context                 # user@hostname
  nordvpn                 # NordVPN 状態 (Linux)
  ranger                  # ranger シェル
  yazi                    # yazi シェル
  nnn                     # nnn シェル
  lf                      # lf シェル
  xplr                    # xplr シェル
  vim_shell               # vim シェル (:sh)
  midnight_commander      # mc シェル
  nix_shell               # nix シェル
  vi_mode                 # vi モード (prompt_char有効時は不要)
  # vpn_ip                # VPN 接続状態
  # load                  # CPU 負荷
  # disk_usage            # ディスク使用量
  # ram                   # メモリ使用量
  # swap                  # スワップ使用量
  todo                    # todo.txt タスク数
  timewarrior             # Timewarrior 追跡状態
  taskwarrior             # Taskwarrior タスク数
  per_directory_history   # ディレクトリ別履歴 (OMZ)
  # cpu_arch              # CPU アーキテクチャ
  time                    # 現在時刻
  # === 2行目 ===
  newline
  # ip                    # IP アドレス / 帯域
  # public_ip             # パブリック IP
  # proxy                 # プロキシ設定
  # battery               # バッテリー
  # wifi                  # WiFi 速度
  # example               # カスタムセグメント例
)
