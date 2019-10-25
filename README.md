# Windows 向け WebRTC ライブラリ用ビルドツール

- libwebrtc m78@{#8}

## About Support

We check PRs or Issues only when written in JAPANESE.
In other languages, we won't be able to deal with them. Thank you for your understanding.

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

`.\build.bat` を実行してください。これで `debug\webrtc.lib` と `release\webrtc.lib` が生成されます。

また、`include` ディレクトリに C++ で扱うためのヘッダファイルが出力されます。必要に応じて使ってください。

## エラーログの取得

Visual Studio のインストールに失敗した場合、`C:\vslogs.zip` にエラーログがあるので、[インストールの失敗の診断](https://docs.microsoft.com/ja-jp/visualstudio/install/advanced-build-tools-container?view=vs-2019#diagnosing-install-failures) を参考にコンテナから取り出して確認する。


## ライセンス

Apache License 2.0

```
Copyright 2019, Shiguredo Inc, melpon and enm10k

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

