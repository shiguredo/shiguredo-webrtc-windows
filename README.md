# Windows 向け WebRTC ライブラリ用ビルドツール

## 概要

このツールは WebRTC ライブラリを Windows 向けにビルドするツールです。
Windows on Docker を利用するため、Docker 以外のツールのインストールは不要です。


## 事前に必要なもの

- Windows 10 Pro または Windows 10 Enterprise 、 Windows サーバが必要です
- Docker for Windows が必要です
    - https://docs.docker.com/docker-for-windows/

## Docker の設定

`Switch to Windows container...` を選択して Windows コンテナを使うようにしてください。

[![Windows コンテナが利用可能になっている状態](https://i.gyazo.com/6c60f2966bd1dbb2681369ac167f6153.png)](https://gyazo.com/6c60f2966bd1dbb2681369ac167f6153)

既に Windows コンテナになってる場合は `Switch to Linux container...` になっているので、この場合は選択する必要はありません。

Docker の Daemon の設定で以下の設定を入れてください。

[![](https://i.gyazo.com/2b4e0aa702fef4db50ea1c62b332153f.png)](https://gyazo.com/2b4e0aa702fef4db50ea1c62b332153f)

```
{
  "registry-mirrors": [],
  "insecure-registries": [],
  "dns": [
    "8.8.8.8"
  ]
}
```

DNS の設定をするのが重要。

特に Windows 10 Pro のバージョンが `Windows 10 Pro Version 1903 (OS Build 18362.239)` である場合、絶対に storage-opts を指定してはいけません。
詳細は https://github.com/docker/for-win/issues/3884#issuecomment-510973455 を参照してください。

## webrtc.lib のビルド

`.\build.bat` を実行してください。これで webrtc.lib が生成されます。

## エラーログの取得

Visual Studio のインストールに失敗した場合、`C:\vslogs.zip` にエラーログがあるので、[インストールの失敗の診断](https://docs.microsoft.com/ja-jp/visualstudio/install/advanced-build-tools-container?view=vs-2019#diagnosing-install-failures) を参考にコンテナから取り出して確認する。
