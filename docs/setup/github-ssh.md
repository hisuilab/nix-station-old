# GitHub SSH 設定

`setup.sh` でシステム構成を適用したあと、GitHub との SSH 接続を設定します。

## 新規鍵を作成する場合

```bash
ssh-keygen -t ed25519 -C "your@email.com" -f ~/.ssh/github_ed25519
```

公開鍵を GitHub に登録します:

```bash
gh auth login                                                  # ブラウザ認証
gh ssh-key add ~/.ssh/github_ed25519.pub --title "$(hostname)"
```

## 既存の鍵を移行する場合

鍵ファイルを `~/.ssh/` にコピーしてから権限を設定します:

```bash
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

## SSH 設定ファイル（任意）

複数の鍵を使い分ける場合は `~/.ssh/config` に追記します:

```
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/github_ed25519
  AddKeysToAgent yes
```

## 動作確認

```bash
ssh -T git@github.com
# Hi <username>! You've successfully authenticated...
```
