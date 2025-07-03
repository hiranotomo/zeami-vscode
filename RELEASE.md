# Zeami VS Code リリースプロセス

## 概要
このドキュメントでは、Zeami VS Codeの正式リリースを作成するプロセスを説明します。

## 前提条件

### 開発環境
- macOS 11.0以上
- Node.js v22.15.1以上
- Xcode Command Line Tools
- Git

### 配布用（オプション）
- Apple Developer Program登録（コード署名用）
- Developer ID Application証明書
- Notarization用のApple ID

## リリースプロセス

### 1. ローカルビルド

#### 開発ビルド（テスト用）
```bash
# 依存関係のインストール
npm install

# TypeScriptのコンパイル
npm run compile

# 簡易起動
./zeami-launcher.sh
```

#### 配布用ビルド
```bash
# macOSアプリバンドルの作成
./build-scripts/build-macos.sh

# アプリのテスト
open "build-output/Zeami VS Code.app"

# DMGインストーラーの作成
./build-scripts/create-dmg.sh
```

### 2. コード署名（オプション）

Apple Developer証明書がある場合：

```bash
# 環境変数の設定
export CODESIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)"

# アプリの署名
./build-scripts/sign-app.sh

# DMGの作成（署名済みアプリを含む）
./build-scripts/create-dmg.sh

# DMGの署名
codesign --force --sign "$CODESIGN_IDENTITY" "build-output/Zeami-VS-Code-Installer-*.dmg"
```

### 3. Notarization（配布用）

App Store外で配布する場合は必須：

```bash
# Notarizationの実行
xcrun notarytool submit "build-output/Zeami-VS-Code-Installer-*.dmg" \
  --apple-id "your@email.com" \
  --team-id "TEAMID" \
  --password "app-specific-password" \
  --wait

# ステープル（認証情報の添付）
xcrun stapler staple "build-output/Zeami-VS-Code-Installer-*.dmg"
```

### 4. GitHub Releaseの作成

#### 自動リリース（推奨）
```bash
# バージョンタグの作成
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# GitHub Actionsが自動的にビルドとリリースドラフトを作成
```

#### 手動リリース
1. GitHubリポジトリの[Releases](https://github.com/hiranotomo/zeami-vscode/releases)ページへ
2. "Draft a new release"をクリック
3. タグとリリースノートを記入
4. ビルド済みDMGファイルをアップロード
5. "Publish release"をクリック

## ビルドスクリプト

### build-macos.sh
- VS Codeのコンパイル
- macOSアプリバンドルの作成
- 依存関係のバンドル

### create-dmg.sh
- DMGインストーラーの作成
- アプリケーションフォルダへのシンボリックリンク追加

### sign-app.sh
- Developer ID証明書でのコード署名
- エンタイトルメントの適用
- 署名の検証

## トラブルシューティング

### ビルドエラー
```bash
# node_modulesのクリーンアップ
rm -rf node_modules
npm install

# ビルドキャッシュのクリア
npm run clean
```

### 署名エラー
- Keychainで証明書の有効性を確認
- `security find-identity -p codesigning`で利用可能な証明書を確認

### Notarizationエラー
- Apple IDの2ファクタ認証を確認
- App-specific passwordを再生成

## CI/CD設定

GitHub Actionsワークフロー（`.github/workflows/build-release.yml`）により、
タグプッシュ時に自動的に：
1. macOS/Windows/Linuxでビルド
2. アーティファクトのアップロード
3. リリースドラフトの作成

## セキュリティ考慮事項

- APIキーや認証情報は絶対にコミットしない
- GitHub Secretsを使用して機密情報を管理
- 配布前に必ずコード署名とNotarizationを実施

## 今後の改善点

- [ ] Windows用インストーラー（.exe/.msi）の作成
- [ ] Linux用パッケージ（.deb/.rpm/.AppImage）の作成
- [ ] 自動アップデート機能の実装
- [ ] 多言語対応の強化