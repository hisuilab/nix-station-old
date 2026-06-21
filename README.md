# nix-station

[![Nix](https://img.shields.io/badge/Nix-5277C3?logo=nixos&logoColor=white)](https://nixos.org/)
[![CI](https://github.com/hisuilab/nix-station/actions/workflows/ci.yml/badge.svg)](https://github.com/hisuilab/nix-station/actions/workflows/ci.yml)
[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## 目次

- [1. 概要](#1-概要)
- [2. 利用を開始する](#2-利用を開始する)
- [3. ドキュメント](#3-ドキュメント)
- [4. License](#4-license)

## 1. 概要

nix-stationは、複数デバイスの開発環境を再現するための、ガイド付きクロスプラットフォーム
開発環境管理基盤です。背景、対象ユーザー、提供価値は
[`REQUIREMENTS.md`](docs/REQUIREMENTS.md)を参照してください。

## 2. 利用を開始する

初回導入は[`セットアップガイド`](docs/SETUP.md)から開始してください。

| 環境 | OS固有ガイド |
|---|---|
| macOS | [`docs/mac/setup.md`](docs/mac/setup.md) |
| Linux・WSL | [`docs/linux/setup.md`](docs/linux/setup.md) |
| Windows | [`docs/windows/setup.md`](docs/windows/setup.md) |

## 3. ドキュメント

文書の読順、責任、情報の正本は[`docs/README.md`](docs/README.md)を参照してください。

> [!IMPORTANT]
> `docs/DESIGN.md`と`docs/architecture/`には未実装の目標設計が含まれます。現行実装との差分は
> [`移行状況`](docs/architecture/README.md#3-移行状況)を確認してください。

## 4. License

[MIT License](LICENSE)
