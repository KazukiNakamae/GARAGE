# バイオインフォマティクスツールのDocker化手順書

## 1. 概要

この手順書では、バイオインフォマティクスツールをDocker化する方法について説明します。Docker化により、環境依存性を排除し、どのようなシステムでも一貫した挙動でツールを実行できるようになります。

## 2. 前提条件

- Git（バージョン管理システム）がインストールされていること
- Docker Desktop（または同等のDocker実行環境）がインストールされていること
- GitHubアカウントを持っていること

## 3. プロジェクト構造

Dockerイメージの作成には以下のファイル構造を推奨します：

```
REPOSITORY_NAME/
├── dockerfiles/
│   └── TOOL_NAME_dockerfile
├── scripts/
│   └── TOOL_NAME_build.sh
└── README.md
```

## 4. Docker化の手順

### 4.1 リポジトリの準備

```bash
# 1. リポジトリをクローン（既存の場合）または新規作成
git clone https://github.com/USERNAME/REPOSITORY_NAME.git
cd REPOSITORY_NAME

# 2. 新しいブランチを作成
git checkout -b TOOL_NAME_docker
```

### 4.2 Dockerfileの作成

`dockerfiles/TOOL_NAME_dockerfile` ファイルを以下のテンプレートを参考に作成します：

```dockerfile
# ベースイメージを指定
FROM ubuntu:22.04

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    # 他の必要なパッケージをここに追加
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 特殊なパッケージのインストール（エラー処理付き）
RUN apt-get update && \
    apt-get install -y PACKAGE_NAME || \
    (echo "Package not found in repositories, trying alternative installation..." && \
    # 代替インストール方法
    cd /tmp && \
    wget PACKAGE_URL && \
    tar -xzf PACKAGE_FILE.tar.gz && \
    cd PACKAGE_DIR && \
    ./configure && \
    make && \
    make install)

# ツールのソースコードをクローンまたはコピー
WORKDIR /app
RUN git clone https://github.com/AUTHOR/TOOL_REPOSITORY.git

# ビルド手順
WORKDIR /app/TOOL_REPOSITORY
RUN mkdir build && cd build && cmake .. && make -j$(nproc)

# 作業ディレクトリを設定
WORKDIR /app/TOOL_REPOSITORY/sample

# コンテナ起動時のコマンド（オプション）
# CMD ["COMMAND_NAME", "--help"]
```

### 4.3 ビルドスクリプトの作成

`scripts/TOOL_NAME_build.sh` ファイルを以下のテンプレートを参考に作成します：

```bash
#!/bin/bash

# スクリプトが存在するディレクトリを取得
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# リポジトリのルートディレクトリを取得
REPO_ROOT="$( cd "$SCRIPT_DIR/.." &> /dev/null && pwd )"

# Dockerfileのパス
DOCKERFILE_PATH="$REPO_ROOT/dockerfiles/TOOL_NAME_dockerfile"

# イメージ名とタグ
IMAGE_NAME="tool-name"
TAG="latest"

echo "==================================================="
echo "TOOL_NAME Dockerイメージのビルドを開始します"
echo "==================================================="
echo "Dockerfileのパス: $DOCKERFILE_PATH"
echo "イメージ名: $IMAGE_NAME:$TAG"
echo "==================================================="

# Dockerイメージのビルド
docker build -t "$IMAGE_NAME:$TAG" -f "$DOCKERFILE_PATH" .

# ビルド結果の確認
if [ $? -eq 0 ]; then
    echo "==================================================="
    echo "ビルドが成功しました！"
    echo "イメージ情報:"
    docker images | grep "$IMAGE_NAME"
    echo ""
    echo "TOOL_NAMEを実行するには以下のコマンドを使用してください："
    echo "docker run -it --rm -v \$(pwd):/data $IMAGE_NAME:$TAG"
    echo "==================================================="
else
    echo "==================================================="
    echo "ビルドに失敗しました。"
    echo "上記のエラーメッセージを確認してください。"
    echo "==================================================="
fi
```

### 4.4 スクリプトに実行権限を付与

```bash
chmod +x scripts/TOOL_NAME_build.sh
```

### 4.5 Dockerイメージのビルド

```bash
./scripts/TOOL_NAME_build.sh
```

### 4.6 変更のコミットとプッシュ

Gitの設定を行い、変更をコミット・プッシュします：

```bash
# GitHubのユーザー名とメールアドレスを設定
git config --global user.name "GITHUB_USERNAME"
git config --global user.email "GITHUB_EMAIL"

# 変更をステージングとコミット
git add dockerfiles/TOOL_NAME_dockerfile scripts/TOOL_NAME_build.sh
git commit -m "Add Docker implementation for TOOL_NAME"

# リモートリポジトリにプッシュ
git push -u origin TOOL_NAME_docker
```

## 5. Docker化の検証

### 5.1 イメージの起動

```bash
docker run -it --rm -v $(pwd):/data tool-name:latest
```

### 5.2 コマンドの実行確認

コンテナ内でツールのコマンドを実行して、正常に動作するか確認します：

```bash
# コンテナIDを確認
docker ps

# コンテナ内でコマンドを実行
docker exec -it CONTAINER_ID COMMAND_NAME -h
```

## 6. トラブルシューティング

### 6.1 パッケージのインストールエラー

特定のパッケージが見つからない場合は以下の対応を検討してください：

1. パッケージ名が正しいか確認する
   - 例：`viennarna` → `vienna-rna`

2. 代替インストール方法を追加する
   - 公式ソースからのダウンロード
   - コンパイル済みバイナリの利用
   - 別のリポジトリの追加

### 6.2 Dockerビルドの最適化

- マルチステージビルドの使用
- 不要なファイルの削除
- `.dockerignore` ファイルの利用

### 6.3 GitHubユーザー名の修正

コミット履歴がローカルユーザー名になってしまった場合は以下の手順で修正します：

```bash
# GitHubユーザー名とメールアドレスを設定
git config --global user.name "GITHUB_USERNAME"
git config --global user.email "GITHUB_EMAIL"

# 最後のコミットの著者情報を更新
git commit --amend --reset-author --no-edit

# 強制プッシュ
git push -f origin BRANCH_NAME
```

## 7. Docker利用のベストプラクティス

### 7.1 データの永続化

ホストとコンテナ間でデータを共有するには、ボリュームマウントを使用します：

```bash
docker run -it --rm -v $(pwd):/data tool-name:latest
```

### 7.2 コンテナのセキュリティ

- ルート権限を必要としないユーザーの作成
- 不要なポートを開放しない
- 最小限の依存関係のみをインストール

### 7.3 ドキュメント化

READMEファイルに以下の情報を記載します：

- ツールの概要と用途
- Dockerイメージの使用方法
- コマンド例と引数の説明
- トラブルシューティング情報

## 8. GitHubとのワークフロー統合

### 8.1 プルリクエストの作成

変更を反映させるためにプルリクエストを作成します：

```
https://github.com/USERNAME/REPOSITORY_NAME/pull/new/TOOL_NAME_docker
```

### 8.2 GitHub Actionsの利用

自動ビルドとテストを実施するための設定例：

```yaml
name: Docker Build

on:
  push:
    branches: [ main, develop, TOOL_NAME_docker ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build Docker image
        run: ./scripts/TOOL_NAME_build.sh
      - name: Test Docker image
        run: docker run --rm tool-name:latest COMMAND_NAME -h
```

## 9. まとめ

このドキュメントに従うことで、バイオインフォマティクスツールを効率的にDocker化し、異なる環境でも一貫して動作させることができます。Docker化により、依存関係の管理、インストールの複雑さ、環境差異による問題が大幅に軽減されます。

---

このドキュメントは、CracklingPlusPlusのDocker化の経験に基づいて作成されました。各ツールの特性に合わせて適宜調整してください。