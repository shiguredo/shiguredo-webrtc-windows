# 変更履歴

- UPDATE
    - 下位互換がある変更
- ADD
    - 下位互換がある追加
- CHANGE
    - 下位互換のない変更
- FIX
    - バグ修正

## master

## m78.8.1

- [ADD] ビルドを GitHub Actions に対応
    - @melpon
- [ADD] WebRTC の各種バージョンを記述した VERSIONS をパッケージに追加
    - @melpon

## m78.8.0

- [ADD] リリース用の release.ps1 を追加
    - release, debug, include, VERSION, NOTICE を zip して webrtc.zip を生成する
    - @voluntas
- [ADD] バージョン用の VERSION を追加
    - @voluntas
- [ADD] NOTICE ファイルを追加
    - @voluntas
- [UPDATE] libwebrtc M78 コミットポジション 8 に変更する
    - libwebrtc のハッシュは 0b2302e5e0418b6716fbc0b3927874fd3a842caf
    - @voluntas
- [UPDATE] libwebrtc M78 コミットポジション 3 に変更する
    - libwebrtc のハッシュは 68c715dc01cd8cd0ad2726453e7376b5f353fcd1
    - @voluntas
