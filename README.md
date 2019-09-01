# Windows 向け WebRTC ライブラリ用ビルドツール

## Docker の設定

`Switch to Windows container...` を選択して Windows コンテナを使うようにする。
既に Windows コンテナになってる場合は `Switch to Linux container...` になっているので、この場合は選択する必要は無い。

この画面で以下の設定を入れる（スクリーンショットと内容が違うが下側のテキストが正しい）。

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

特に Windows 10 Pro のバージョンが `Windows 10 Pro Version 1903 (OS Build 18362.239)` である場合、絶対に storage-opts を指定してはいけない。
詳細は https://github.com/docker/for-win/issues/3884#issuecomment-510973455 を参照。

## webrtc.lib のビルド

`.\build.bat` を実行する。これで webrtc.lib が生成される。

## エラーログの取得

Visual Studio のインストールに失敗した場合、`C:\vslogs.zip` にエラーログがあるので、[インストールの失敗の診断](https://docs.microsoft.com/ja-jp/visualstudio/install/advanced-build-tools-container?view=vs-2019#diagnosing-install-failures) を参考にコンテナから取り出して確認する。
