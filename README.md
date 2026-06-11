# Nix Station

[![Nix](https://img.shields.io/badge/Nix-5277C3?logo=nixos&logoColor=white)](https://nixos.org/)
[![CI](https://github.com/hisuilab/nix-station/actions/workflows/ci.yml/badge.svg)](https://github.com/hisuilab/nix-station/actions)
[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

> Nixの学習コストをゼロに。
> 1枚の設定ファイル（`.nix`）のフラグを切り替えるだけで、OSレイヤーの設定、モダンなZshターミナル、性能を引き出すシステム設定、そしてDevboxによる開発ワークスペースを全自動で構築・再現するコンポーネント型テンプレート。

---

## Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
- [Directory Structure](#directory-structure)
- [Development and Contributing](#development-and-contributing)
- [License](#license)

---

## Features

- **Zero Learning Curve**: Nixの複雑な構文を覚える必要はありません。フラグを `true` / `false` にするだけで環境が完成します。
- **Component-Driven Architecture**: すべての機能（Zsh, Git, Devbox, Homebrew）が `packages/` 単位でカプセル化されており、自由に組み合わせ可能です。
- **Multi-OS and Role Matrix**: Mac miniサーバー（常時駆動・スリープ無効）から、MacBook（Laptop用GUI環境）、Linux、Raspberry Piまで、単一リポジトリで直交管理します。

---

## Quick Start

### 1. Clone and Initialize Registry

環境を構築したいマシンで以下を実行します。

```bash
git clone https://github.com/hisuilab/nix-station.git
cd nix-station
```
