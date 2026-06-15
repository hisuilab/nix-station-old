# flake inputs 更新ログ

日付: 2026-06-15

目的: nixpkgs / nix-darwin / home-manager を 25.05 ブランチの最新コミットに追従させ、
      ビルド時の deprecation 警告を解消する。

---

## 背景

`darwin-rebuild switch` 実行時に 2 件の deprecation 警告が出ていた。

```
evaluation warning: `programs.zsh.initExtra` is deprecated,
  use `programs.zsh.initContent` instead.

warning: `activate-user` is deprecated and will be removed in 25.11
```

現在のピン: nixpkgs / nix-darwin / home-manager すべて `25.05` ブランチ。  
2026-06 時点で 25.05 は EOL 相当 (25.11, 26.05 がリリース済み) だが、
ブランチ内の最新コミットへの追従は未実施だった。

---

## 実施内容

### 1. `programs.zsh.initExtra` → `initContent` 修正

home-manager 25.05 で `initExtra` が deprecated になったため修正。

```nix
# 修正前
programs.zsh.initExtra = ''...''

# 修正後
programs.zsh.initContent = ''...''
```

対象ファイル:
- `modules/home/p10k/default.nix`
- `tests/home/app-configs/default.nix` (テスト内の参照も同様に更新)

### 2. `nix flake update` 実行

```bash
nix flake update
```

GitHub API が断続的に 504 を返したが、リトライにより完了。  
flake.lock の差分なし — 25.05 ブランチ上のピンがすでに最新だった。

### 3. `nix flake check` 実行 → 失敗

```
error: user profile 'hisuilab.nix' does not exist in '...-source/user-profiles'
```

---

## 課題と原因

### `macMiniEval` / `macbookAirEval` が `nix flake check` で失敗

**原因:**  
`flake.nix` の `checks` ブロックに実ホスト評価が含まれていた。

```nix
macMiniEval    = self.darwinConfigurations.mac-mini.system;
macbookAirEval = self.darwinConfigurations.macbook-air.system;
```

これらは `user-profiles/hisuilab.nix` を必要とするが、同ファイルは
個人情報を含むため `.gitignore` で意図的に除外されている。  
nix は flake のソースを評価するとき git の追跡対象ファイルのみをストアに
コピーするため、gitignore されたファイルは参照できない。

**影響範囲:**  
- `nix flake check` は常に失敗していた (flake 追加当初から潜在的な問題)
- `darwin-rebuild switch` は影響なし (ローカル作業ディレクトリを直接参照するため)

### `activate-user` 警告

**原因:**  
home-manager の nix-darwin モジュールが旧来の `activate-user` 方式を使用している。  
nix-darwin 25.05 でこの方式は deprecated になり、25.11 で削除予定だった。

**現状:**  
25.11 / 26.05 はすでにリリース済みだが、当リポジトリは 25.05 にピン留め中のため
現時点では動作に影響なし。  
26.05 へのメジャーアップグレード時に home-manager 側の対応込みで解消される見込み。

---

## 対処

### `macMiniEval` / `macbookAirEval` をモック評価に置換

`self.darwinConfigurations.mac-mini.system` (実 userProfile が必要) の代わりに、
`mkDarwinConfiguration` を直接呼んで `testUserProfile` を差し込む方式に変更。

```nix
# flake.nix checks ブロック
macMiniMockEval = (mkDarwinConfiguration {
  hostConfig   = validatedHostConfigs."mac-mini";
  hostId       = "mac-mini";
  userProfile  = testUserProfile;   # gitignore対象の hisuilab.nix の代替
}).system;

macbookAirMockEval = (mkDarwinConfiguration {
  hostConfig   = validatedHostConfigs."macbook-air";
  hostId       = "macbook-air";
  userProfile  = testUserProfile;
}).system;
```

**保証できること:** ホスト固有の設定 (darwin.features, darwin.homebrew, homeManager フラグ) の構造的な正当性  
**保証できないこと:** 実際のユーザー名・メールアドレスなどユーザープロファイル依存の値の正確性  
→ それは `darwin-rebuild switch` のローカル実行で担保する

### `activate-user` 警告

対処なし。26.05 へのアップグレード時に合わせて対応する。

---

## 結果

```
nix flake check  →  全チェック通過 (警告なし)
```

---

## 今後の対応

26.05 へのメジャーアップグレードを行う際は以下を同時に更新する。

```nix
# flake.nix
nixpkgs.url       = "github:nixos/nixpkgs/nixos-26.05";
nix-darwin.url    = "github:LnL7/nix-darwin/nix-darwin-26.05";
home-manager.url  = "github:nix-community/home-manager/release-26.05";
```

`activate-user` 警告の解消と、各モジュールの breaking changes 確認を併せて行うこと。
