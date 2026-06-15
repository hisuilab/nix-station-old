# ============================================================
# terraform: Terraform ワークスペース
# ============================================================
# default ワークスペースは非表示
typeset -g POWERLEVEL9K_TERRAFORM_SHOW_DEFAULT=false
typeset -g POWERLEVEL9K_TERRAFORM_CLASSES=(
    # '*prod*'  PROD
    # '*test*'  TEST
    '*'         OTHER)
typeset -g POWERLEVEL9K_TERRAFORM_OTHER_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_TERRAFORM_OTHER_BACKGROUND=$C_NEON_PURPLE

# ============================================================
# terraform_version: Terraform バージョン
# ============================================================
typeset -g POWERLEVEL9K_TERRAFORM_VERSION_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_TERRAFORM_VERSION_BACKGROUND=$C_NEON_PURPLE
# terraform/tf コマンド入力時のみ表示
typeset -g POWERLEVEL9K_TERRAFORM_VERSION_SHOW_ON_COMMAND='terraform|tf'

# ============================================================
# kubecontext: Kubernetes コンテキスト
# ============================================================
# kubectl 等のコマンド入力時のみ表示
typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|helm|kubens|kubectx|oc|istioctl|kogito|k9s|helmfile|flux|fluxctl|stern|kubeseal|skaffold|kubent|kubecolor|cmctl|sparkctl'
typeset -g POWERLEVEL9K_KUBECONTEXT_CLASSES=(
    # '*prod*'  PROD
    # '*test*'  TEST
    '*'       DEFAULT)
typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_BACKGROUND=$C_INDIGO
# 表示フォーマット (クラスタ名/ネームスペース)
typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_CONTENT_EXPANSION=
POWERLEVEL9K_KUBECONTEXT_DEFAULT_CONTENT_EXPANSION+='${P9K_KUBECONTEXT_CLOUD_CLUSTER:-${P9K_KUBECONTEXT_NAME}}'
POWERLEVEL9K_KUBECONTEXT_DEFAULT_CONTENT_EXPANSION+='${${:-/$P9K_KUBECONTEXT_NAMESPACE}:#/default}'

# ============================================================
# aws: AWS プロファイル
# ============================================================
# aws 等のコマンド入力時のみ表示
typeset -g POWERLEVEL9K_AWS_SHOW_ON_COMMAND='aws|awless|cdk|terraform|pulumi|terragrunt'
typeset -g POWERLEVEL9K_AWS_CLASSES=(
    # '*prod*'  PROD
    # '*test*'  TEST
    '*'       DEFAULT)
typeset -g POWERLEVEL9K_AWS_DEFAULT_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_AWS_DEFAULT_BACKGROUND=$C_NEON_PURPLE
# 表示フォーマット (プロファイル名 リージョン)
typeset -g POWERLEVEL9K_AWS_CONTENT_EXPANSION='${P9K_AWS_PROFILE//\%/%%}${P9K_AWS_REGION:+ ${P9K_AWS_REGION//\%/%%}}'

# ============================================================
# aws_eb_env: AWS Elastic Beanstalk
# ============================================================
typeset -g POWERLEVEL9K_AWS_EB_ENV_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_AWS_EB_ENV_BACKGROUND=$C_NEON_PURPLE

# ============================================================
# azure: Azure アカウント
# ============================================================
# az 等のコマンド入力時のみ表示
typeset -g POWERLEVEL9K_AZURE_SHOW_ON_COMMAND='az|terraform|pulumi|terragrunt'
typeset -g POWERLEVEL9K_AZURE_CLASSES=(
    # '*prod*'  PROD
    # '*test*'  TEST
    '*'         OTHER)
typeset -g POWERLEVEL9K_AZURE_OTHER_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_AZURE_OTHER_BACKGROUND=$C_SUCCESS_ALT

# ============================================================
# gcloud: Google Cloud
# ============================================================
# gcloud 等のコマンド入力時のみ表示
typeset -g POWERLEVEL9K_GCLOUD_SHOW_ON_COMMAND='gcloud|gcs|gsutil'
typeset -g POWERLEVEL9K_GCLOUD_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_GCLOUD_BACKGROUND=$C_INDIGO
# プロジェクト名取得前
typeset -g POWERLEVEL9K_GCLOUD_PARTIAL_CONTENT_EXPANSION='${P9K_GCLOUD_PROJECT_ID//\%/%%}'
# プロジェクト名取得後
typeset -g POWERLEVEL9K_GCLOUD_COMPLETE_CONTENT_EXPANSION='${P9K_GCLOUD_PROJECT_NAME//\%/%%}'
# プロジェクト名の更新間隔 (秒 / 負数=設定変更時のみ)
typeset -g POWERLEVEL9K_GCLOUD_REFRESH_PROJECT_NAME_SECONDS=60

# ============================================================
# google_app_cred: Google 認証情報
# ============================================================
typeset -g POWERLEVEL9K_GOOGLE_APP_CRED_SHOW_ON_COMMAND='terraform|pulumi|terragrunt'
typeset -g POWERLEVEL9K_GOOGLE_APP_CRED_CLASSES=(
    # '*:*prod*:*'  PROD
    # '*:*test*:*'  TEST
    '*'             DEFAULT)
typeset -g POWERLEVEL9K_GOOGLE_APP_CRED_DEFAULT_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_GOOGLE_APP_CRED_DEFAULT_BACKGROUND=$C_INDIGO
typeset -g POWERLEVEL9K_GOOGLE_APP_CRED_DEFAULT_CONTENT_EXPANSION='${P9K_GOOGLE_APP_CRED_PROJECT_ID//\%/%%}'

# ============================================================
# toolbox: Toolbox 名
# ============================================================
typeset -g POWERLEVEL9K_TOOLBOX_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_TOOLBOX_BACKGROUND=$C_SUCCESS_ALT
# fedora-toolbox-* は非表示
typeset -g POWERLEVEL9K_TOOLBOX_CONTENT_EXPANSION='${P9K_TOOLBOX_NAME:#fedora-toolbox-*}'
