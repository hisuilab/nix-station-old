# ドキュメント索引

> [!IMPORTANT]
> この文書は、nix-stationのドキュメント責任と参照先の正本です。同じ情報を複数文書へ
> 記載せず、所有文書へリンクします。

## 目次

- [1. 読み方](#1-読み方)
- [2. 文書責任](#2-文書責任)
- [3. 設計文書](#3-設計文書)
- [4. 運用・実装文書](#4-運用実装文書)
- [5. 履歴文書](#5-履歴文書)

## 1. 読み方

| 目的 | 読む順番 |
|---|---|
| 利用を開始する | [`SETUP`](setup/README.md) → 対象OSガイド |
| プロダクトを理解する | [`REQUIREMENTS`](REQUIREMENTS.md) → [`DESIGN`](DESIGN.md) |
| 設計をレビューする | [`DESIGN`](DESIGN.md) → 対象の詳細設計 → Decision Record |
| 実装を変更する | [`DEVELOPMENT`](DEVELOPMENT.md) → 対象Module README → 対応Test |
| AIエージェントで変更する | [`ai/context_policy`](ai/context_policy.md) → 対象文書 |

## 2. 文書責任

| 文書 | 所有する情報 | 所有しない情報 |
|---|---|---|
| [`README`](../README.md) | プロジェクト入口、主要リンク | 詳細手順、設計契約 |
| [`REQUIREMENTS`](REQUIREMENTS.md) | 背景、価値、対象者、要件、対象外 | 内部構造、操作手順 |
| [`DESIGN`](DESIGN.md) | 全体構造、責務境界、主要判断 | サブシステム詳細、開発手順 |
| [`architecture/`](architecture/README.md) | 詳細設計、依存、失敗時動作、移行状況 | 現行操作コマンド |
| [`SETUP`](setup/README.md) | 共通の初回導入手順 | OS固有の制約、日常適用 |
| OS別ガイド | OS固有の管理範囲、制約、適用方法 | 共通の取得・導入手順 |
| [`DEVELOPMENT`](DEVELOPMENT.md) | 現行実装の拡張方法、検証コマンド | 要件、設計判断、AI固有ルール |
| [`setup/nix/`](setup/nix/hosts.md) | 現行Nix設定の利用方法 | 目標アーキテクチャ |
| [`ai/`](ai/context_policy.md) | AI固有の読込、リスク、承認、レビュー | プロダクト要件、設計本文 |

## 3. 設計文書

| 問い | 正本 |
|---|---|
| なぜ必要か、誰に何を提供するか | [`REQUIREMENTS.md`](REQUIREMENTS.md) |
| システムをどの責任へ分けるか | [`DESIGN.md`](DESIGN.md) |
| 個人設定をどこへ置き、どう適用するか | [`instance-and-deployment.md`](architecture/instance-and-deployment.md) |
| 初回導入とWizardの責任は何か | [`user-workflow.md`](architecture/user-workflow.md) |
| アプリとDockをどう管理するか | [`app-management.md`](architecture/app-management.md) |
| TestとCIで何を保証するか | [`testing.md`](architecture/testing.md) |
| 現行実装からの移行状況 | [`architecture/README.md`](architecture/README.md#3-移行状況) |

## 4. 運用・実装文書

| 問い | 正本 |
|---|---|
| 初回セットアップ | [`setup/README.md`](setup/README.md) |
| macOS固有の適用 | [`setup/mac.md`](setup/mac.md) |
| Linux・WSL固有の適用 | [`setup/linux.md`](setup/linux.md) |
| WindowsとWSL導入 | [`setup/windows.md`](setup/windows.md) |
| 現行Host設定 | [`setup/nix/hosts.md`](setup/nix/hosts.md) |
| 現行User Profile | [`setup/nix/user-profiles.md`](setup/nix/user-profiles.md) |
| direnv | [`setup/nix/direnv.md`](setup/nix/direnv.md) |
| GitHub SSH | [`setup/github-ssh.md`](setup/github-ssh.md) |
| 開発とローカル検証 | [`DEVELOPMENT.md`](DEVELOPMENT.md) |

## 5. 履歴文書

`decisions/`は判断時点の選択と理由、`reviews/`は調査・レビュー時点の証跡を保存します。
履歴は現行仕様の正本ではありません。現行仕様が変わった場合は要件・設計・運用文書を更新し、
履歴文書は当時の記録として保持します。
