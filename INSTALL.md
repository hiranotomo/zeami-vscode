# Zeami VS Code インストールガイド

## 概要
Zeami VS Codeは、VS Code（Code-OSS）にZeamiフレームワークの統合機能を追加したカスタマイズ版です。

## インストール方法

### 1. 前提条件
- **Node.js**: v22.15.1以上
- **Git**: 2.x以上
- **macOS**: Xcode Command Line Tools

### 2. クローンとセットアップ

```bash
# リポジトリのクローン
git clone https://github.com/hiranotomo/zeami-vscode.git
cd zeami-vscode

# Node.jsバージョンの設定（nvmを使用する場合）
nvm install 22.15.1
nvm use 22.15.1

# 依存関係のインストール
npm install
```

### 3. ビルド

```bash
# TypeScriptのコンパイル
npm run compile
```

### 4. 起動

```bash
# macOS/Linux
./scripts/code.sh

# Windows
./scripts/code.bat
```

## 開発環境での使用

### ファイル監視モード
```bash
npm run watch
```

### デバッグ
VS Code内で`F5`を押すか、デバッグパネルから「Launch VS Code」を選択してください。

## カスタマイズ内容

- **Zeami統合**: Zeamiフレームワークとの連携機能
- **拡張機能**: カスタム拡張機能セット
- **UI改善**: 開発者向けのUI調整

## トラブルシューティング

### ビルドエラーが発生する場合
```bash
# node_modulesをクリーンアップ
rm -rf node_modules
npm install
```

### 起動しない場合
```bash
# ログを確認
./scripts/code.sh --verbose
```

## 更新履歴

- 2025-07-03: 初版リリース

## ライセンス

このプロジェクトはMIT Licenseのもとで公開されています。
VS Code本体のライセンスについては、[元のリポジトリ](https://github.com/microsoft/vscode)を参照してください。

## 貢献

バグ報告や機能提案は[Issues](https://github.com/hiranotomo/zeami-vscode/issues)にお願いします。

## 関連リンク

- [Zeamiフレームワーク](https://github.com/hiranotomo/Zeami-1)
- [VS Code公式](https://github.com/microsoft/vscode)