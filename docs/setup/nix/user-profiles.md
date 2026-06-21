# ユーザープロファイル

ホストが使用するプロファイルは各 `hosts/<host-id>/config.nix` で選択します。

```nix
userProfile = {
  name = "guest";
};
```

この例では [`user-profiles/guest.nix`](../../user-profiles/guest.nix) が読み込まれます。

```text
userProfile.name = "test"
        ↓
user-profiles/test.nix
```

## プロファイルの形式

```nix
{
  username = "example";
  description = "Optional description";
  git = {
    userName = "example";
    userEmail = "example@example.com";
  };
}
```

必須項目は `username`、`git.userName`、`git.userEmail` です。未定義、空文字、型不正、または指定ファイルが存在しない場合は評価エラーになります。`description` は省略できます。

## .gitignore とプロファイル管理

`guest.nix` とリポジトリテスト用の `test.nix` を除き、`user-profiles/*.nix` はデフォルトで Git のコミット対象外です。個人情報を含むプロファイルはローカルで作成し、各ホストの `userProfile.name` を任意の名前へ変更してください。

チームで共有するプロファイルや CI で評価するプロファイルは、`.gitignore` へ例外を追加して Git で追跡します。

Flake は通常、Git で追跡されているファイルを入力として評価します。純粋な `nix flake check` や CI で使用するプロファイルは Git へ追加してください。`.gitignore` 対象のローカルプロファイルは CI には含まれません。
