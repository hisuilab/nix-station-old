# Mac Mini nix-station セットアップログ

日付: 2026-06-14

---

## 事前確認

`nix build` はユーザー権限で成功済み：

```bash
nix build path:.#darwinConfigurations.mac-mini.system --no-link
```

---

## エラー 1: sudo nix run で nix-command が無効になる

### 実行コマンド

```bash
sudo nix run github:LnL7/nix-darwin/nix-darwin-24.11#darwin-rebuild -- \
  switch --flake path:.#mac-mini
```

### エラー内容

```
warning: $HOME ('/Users/hisuilab') is not owned by you, falling back to the one defined in the 'passwd' file ('/var/root')
error: experimental Nix feature 'nix-command' is disabled; add '--extra-experimental-features nix-command' to enable it
```

### 原因

- `~/.config/nix/nix.conf` に `experimental-features = nix-command flakes` が設定されているのはユーザー (`hisuilab`) のみ
- `sudo nix run` はroot (`/var/root`) として実行されるため、ユーザー設定が読み込まれない
- `darwin-rebuild` は内部で必要な権限昇格を行うため、`sudo` は不要

### 対処（成功）

`sudo` を外してユーザー権限で実行する：

```bash
nix run github:LnL7/nix-darwin/nix-darwin-24.11#darwin-rebuild -- \
  switch --flake path:.#mac-mini
```

---

## エラー 2: brew 4.5.0 が macOS 26 (Tahoe) を未対応

### 実行コマンド

```bash
nix run github:LnL7/nix-darwin/nix-darwin-24.11#darwin-rebuild -- \
  switch --flake path:.#mac-mini
```

### エラー内容

```
/nix/store/x2av253lp6s29i5kg150cgrwl4i3im8b-brew-4.5.0-patched/Library/Homebrew/macos_version.rb:53:in 'MacOSVersion#initialize': unknown or unsupported macOS version: "26.5.1" (MacOSVersion::Error)
```

### 原因

- `flake.nix` の `nix-homebrew` が 2025-05-05 時点のコミット (`20e4702...`) に固定されていた
- このコミットに含まれる `brew-4.5.0-patched` は macOS 26 (Tahoe) を未サポート
- システム設定 (Dock、user defaults) は成功。失敗は `Homebrew bundle` のみ

### 対処（実施済み）

1. `flake.nix` の nix-homebrew URL からコミット固定を除去:
   ```nix
   # 変更前
   url = "github:zhaofengli/nix-homebrew/20e4702906fb0a8de16902621689cafef445a35d";
   # 変更後
   url = "github:zhaofengli/nix-homebrew";
   ```
2. 新バージョンでは `inputs.nixpkgs.follows` と `inputs.nix-darwin.follows` が不要になったため削除

3. ロック更新実行:

   ```bash
   nix flake update nix-homebrew
   ```

   - nix-homebrew: `20e4702` (2025-05-05) → `de7953a` (2026-06-13)
   - brew-src: 2025-04-29 → 2026-06-12

4. 再実行:
   ```bash
   nix run github:LnL7/nix-darwin/nix-darwin-24.11#darwin-rebuild -- \
     switch --flake path:.#mac-mini
   ```

---

## エラー 3: nix-homebrew HEAD が nix-darwin-24.11 の system-wide activation を要求

### 実行コマンド

```bash
nix run github:LnL7/nix-darwin/nix-darwin-24.11#darwin-rebuild -- \
  switch --flake path:.#mac-mini
```

### エラー内容

```
error:
Failed assertions:
- Please update your nix-darwin version to use system-wide activation
```

### 原因

- 最新の nix-homebrew (2026-06-13) が nix-darwin の "system-wide activation" 機能を必要とする
- `nix-darwin-24.11` はこの機能を未実装
- nixpkgs / nix-darwin / home-manager を一括して 25.05 に更新する必要あり

### 対処（実施済み）

`flake.nix` のチャンネルを 24.11 → 25.05 に変更し `nix flake update` を実行:

| input        | 変更前                        | 変更後                        |
| ------------ | ----------------------------- | ----------------------------- |
| nixpkgs      | nixos-24.11 (2025-06-30)      | nixos-25.05 (2026-01-02)      |
| nix-darwin   | nix-darwin-24.11 (2025-03-28) | nix-darwin-25.05 (2026-01-28) |
| home-manager | release-24.11 (2025-05-19)    | release-25.05 (2025-11-24)    |

再実行コマンド:

```bash
nix run github:LnL7/nix-darwin/nix-darwin-25.05#darwin-rebuild -- \
  switch --flake path:.#mac-mini
```

---

## エラー 4: nix-darwin-25.05 は root 実行が必須

### 実行コマンド

```bash
nix run github:LnL7/nix-darwin/nix-darwin-25.05#darwin-rebuild -- \
  switch --flake path:.#mac-mini
```

### エラー内容

```
/nix/store/.../darwin-rebuild: system activation must now be run as root
```

### 原因

- nix-darwin 25.05 からシステム activation が root 実行必須に変更された
- 単純に `sudo nix run` するとエラー 1 の再発（root の nix.conf に experimental-features なし）

### 対処

`--extra-experimental-features` を `nix` 自体へのフラグとして渡し、`sudo` と組み合わせる:

```bash
sudo nix --extra-experimental-features 'nix-command flakes' \
  run github:LnL7/nix-darwin/nix-darwin-25.05#darwin-rebuild -- \
  switch --flake path:.#mac-mini
```

---

## エラー 5: system.primaryUser が未設定

### 実行コマンド

```bash
sudo nix --extra-experimental-features 'nix-command flakes' \
  run github:LnL7/nix-darwin/nix-darwin-25.05#darwin-rebuild -- \
  switch --flake path:.#mac-mini
```

### エラー内容

```
error:
Failed assertions:
- Previously, some nix-darwin options applied to the user running `darwin-rebuild`.
  As part of a long-term migration to make nix-darwin focus on system-wide activation
  and support first-class multi-user setups, all system activation now runs as `root`,
  and these options instead apply to the `system.primaryUser` user.

  To continue using these options, set `system.primaryUser` to the name
  of the user you have been using to run `darwin-rebuild`.
```

対象オプション: `homebrew.enable`, `system.defaults.dock.*`, `system.defaults.finder.*`, etc.

### 原因

- nix-darwin 25.05 から、Dock・Finder・Homebrew 等のユーザースコープ設定は
  `system.primaryUser` で指定したユーザーに適用される仕様に変更

### 対処（実施済み）

`modules/system/darwin/default.nix` に `system.primaryUser = username;` を追加:

```nix
config = {
  # nix-darwin 25.05: user-scoped オプションの適用対象ユーザーを指定
  system.primaryUser = username;
  ...
};
```

`username` は `userProfile.username` から既に取得済みのため、追加行のみで対応完了。

---

## エラー 6: nix-homebrew HEAD が ruby_4_0 を要求するが nixpkgs-25.05 に未収録

### エラー内容

```
error: attribute 'ruby_4_0' missing
at «github:zhaofengli/nix-homebrew/de7953a...»/modules/default.nix:38:10:
  ruby = pkgs.ruby_4_0;
Did you mean one of ruby_3_1, ruby_3_2, ruby_3_3 or ruby_3_4?
```

### 原因

- nix-homebrew HEAD (2026-06-13) の内部で `pkgs.ruby_4_0` を参照
- nixpkgs-25.05 には `ruby_3_4` までしか存在しない
- nix-darwin モジュールの `pkgs` はシステムの nixpkgs-25.05 が使われるため不足

### 対処（実施済み）

`modules/system/darwin/core/default.nix` に nixpkgs overlay を追加し、
nixpkgs-unstable（既存 flake input）から `ruby_4_0` を補完:

```nix
nixpkgs.overlays = [
  (final: prev: {
    ruby_4_0 = nixpkgsUnstable.legacyPackages.${prev.system}.ruby_4_0;
  })
];
```

---

## エラー 7: davinci-resolve が Homebrew cask から廃止

### エラー内容

```
Error: No available formula with the name "davinci-resolve".
`brew bundle` failed!
```

`brew search davinci` でも見つからず。Blackmagic Design が Homebrew 経由での配布を終了。

### 対処（実施済み）

`hosts/mac-mini/config.nix` から `"davinci-resolve"` を削除し、コメントを追記。
DaVinci Resolve は公式サイトから手動インストールが必要。

---

## エラー 8: brew bundle の部分失敗 (zed / docker-desktop / MAS アプリ)

### 状況

大部分の cask は正常インストール済み。以下3件が失敗。

---

### 8a: zed と docker-desktop の xattr EPERM

```
Error: Failure while executing; `/usr/bin/xattr -w com.apple.metadata:kMDItemAlternateNames \
  ("zed") /Applications/Zed.app/Contents/MacOS/cli` exited with 1.
xattr: [Errno 1] Operation not permitted
```

**原因**: macOS 26 (Tahoe) で署名済みアプリバンドル内バイナリへの xattr 書き込みが拒否される。
既存インストール（別ソース）の「adopt（採用）」時に発生。

**重要**: brew はロールバック時にアプリを削除するため、次回実行では既存アプリとの競合がなく新規インストールになる。
2回目の `darwin-rebuild switch` で解消する見込み。

---

### 8b: MAS アプリ (GarageBand / RunCat / Xcode) の失敗

```
Installing GarageBand has failed!
Installing RunCat has failed!
Installing Xcode has failed!
```

**原因**: `mas` (Mac App Store CLI) が Apple ID 認証を要求するが、初回セットアップ時は未サインイン。

**対処**: App Store アプリに手動でサインインしてから再実行。

```bash
# App Store でサインイン後
sudo nix --extra-experimental-features 'nix-command flakes' \
  run github:LnL7/nix-darwin/nix-darwin-25.05#darwin-rebuild -- \
  switch --flake path:.#mac-mini
```

---

### 8c: ollama cask 改名

```
Warning: Cask ollama was renamed to ollama-app.
```

`hosts/mac-mini/config.nix` で `"ollama"` → `"ollama-app"` に修正済み。

---

## 進行中のエラー・成功記録

（以降、コマンド実行ごとに追記）
