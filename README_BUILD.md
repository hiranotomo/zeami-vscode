# VS Code ビルド手順と結果

## 概要
VS Code（Code-OSS）のオープンソース版をGitHubからクローンし、ローカルでビルド環境を構築しました。

## 環境要件
- **Node.js**: v22.15.1以上（必須）
- **Python**: 3.x（node-gypのため）
- **Git**: 2.x以上
- **macOS**: Xcode Command Line Tools
- **メモリ**: 最低6GB（推奨8GB）

## ビルド手順

### 1. リポジトリのクローン
```bash
git clone https://github.com/microsoft/vscode.git vscode-clone
```

### 2. Node.jsバージョンの設定
```bash
nvm install 22.15.1
nvm use 22.15.1
```

### 3. 依存関係のインストール
```bash
npm install
```
- 全拡張機能の依存関係も自動的にインストールされます
- 約2分で完了

### 4. ビルド実行
```bash
npm run compile
```
- 初回ビルドは約1分30秒で完了
- TypeScriptのコンパイルとextensionsのビルドを含む

## ビルド結果
- ✅ コアのTypeScriptコンパイル：成功（0エラー）
- ✅ 全拡張機能のビルド：成功（0エラー）
- ✅ Monaco Editorの型チェック：成功

## VS Codeの起動
ビルドしたVS Codeを起動するには：
```bash
./scripts/code.sh  # macOS/Linux
# または
./scripts/code.bat  # Windows
```

## プロジェクト構造
```
vscode-clone/
├── src/              # VS Codeコアのソースコード
├── extensions/       # 組み込み拡張機能
├── out/             # コンパイル済みコード
├── build/           # ビルドスクリプト
├── scripts/         # ユーティリティスクリプト
└── package.json     # プロジェクト設定
```

## 開発Tips
- `npm run watch`：ファイル変更を監視して自動再コンパイル
- `npm run test`：テストスイートの実行
- `npm run eslint`：コード品質チェック

## 参考リンク
- [VS Code GitHub リポジトリ](https://github.com/microsoft/vscode)
- [How to Contribute](https://github.com/microsoft/vscode/wiki/How-to-Contribute)
- [Development Process](https://github.com/microsoft/vscode/wiki/Development-Process)