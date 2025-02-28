# CracklingPlusPlusのDocker化実践ガイド

## 1. 概要

本ドキュメントでは、実際のバイオインフォマティクスツール「CracklingPlusPlus」をDocker化した手順を例に、効率的なDocker化の流れとベストプラクティスを解説します。Docker化により、ツールの利用環境の差異を排除し、再現性の高い計算環境を提供することができます。

## 2. 前提条件

- macOS環境（またはLinux/Windows環境）
- Git（バージョン管理システム）がインストール済み
- Docker Desktop（または同等のDocker実行環境）がインストール済み
- GitHubアカウント

## 3. CracklingPlusPlusのDocker化：ステップバイステップガイド

### 3.1 リポジトリのクローンと新規ブランチの作成

```bash
# リポジトリのクローン
git clone https://github.com/KazukiNakamae/GARAGE.git
cd GARAGE

# Docker化用の新しいブランチを作成
git checkout -b CracklingPlusPlus_docker
```

### 3.2 プロジェクト構造の設定

CracklingPlusPlusのDocker化に必要なファイル構造を作成します：

```bash
# ディレクトリ構造が存在しない場合は作成
mkdir -p dockerfiles scripts
```

最終的なディレクトリ構成：
```
GARAGE/
├── dockerfiles/
│   └── CracklingPlusPlus_dockerfile
├── scripts/
│   └── CracklingPlusPlus_build.sh
└── README.md
```

### 3.3 Dockerfileの作成

`dockerfiles/CracklingPlusPlus_dockerfile` を以下の内容で作成します：

```dockerfile
# ベースイメージとしてUbuntu 22.04を使用
FROM ubuntu:22.04

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    unzip \
    libboost-all-dev \
    bowtie2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ViennaRNAパッケージのインストール - 方法1: パッケージマネージャ
RUN apt-get update && \
    apt-get install -y vienna-rna || \
    (echo "Vienna RNA package not found in repositories, trying alternative installation..." && \
    # 方法2: ソースからのインストール（方法1が失敗した場合）
    cd /tmp && \
    wget https://www.tbi.univie.ac.at/RNA/download/sourcecode/2_5_x/ViennaRNA-2.5.0.tar.gz && \
    tar -xzf ViennaRNA-2.5.0.tar.gz && \
    cd ViennaRNA-2.5.0 && \
    ./configure --without-perl --without-python && \
    make && \
    make install && \
    ldconfig && \
    cd / && \
    rm -rf /tmp/ViennaRNA*)

# CracklingPlusPlusのソースコードをクローン
WORKDIR /app
RUN git clone https://github.com/bmds-lab/CracklingPlusPlus.git

# CracklingPlusPlusのビルド
WORKDIR /app/CracklingPlusPlus
RUN mkdir build && cd build && cmake .. && make -j$(nproc)

# サンプルディレクトリを作業ディレクトリに設定
WORKDIR /app/CracklingPlusPlus/sample
```

### 3.4 ビルドスクリプトの作成

`scripts/CracklingPlusPlus_build.sh` を以下の内容で作成します：

```bash
#!/bin/bash

# スクリプトが存在するディレクトリを取得
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# GARAGEリポジトリのルートディレクトリを取得
REPO_ROOT="$( cd "$SCRIPT_DIR/.." &> /dev/null && pwd )"

# Dockerfileのパス
DOCKERFILE_PATH="$REPO_ROOT/dockerfiles/CracklingPlusPlus_dockerfile"

# イメージ名とタグ
IMAGE_NAME="crackling-plus-plus"
TAG="latest"

echo "==================================================="
echo "CracklingPlusPlus Dockerイメージのビルドを開始します"
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
    echo "CracklingPlusPlusを実行するには以下のコマンドを使用してください："
    echo "docker run -it --rm -v \$(pwd):/data $IMAGE_NAME:$TAG"
    echo "==================================================="
else
    echo "==================================================="
    echo "ビルドに失敗しました。"
    echo "上記のエラーメッセージを確認してください。"
    echo "==================================================="
fi
```

### 3.5 スクリプトに実行権限を付与

```bash
chmod +x scripts/CracklingPlusPlus_build.sh
```

### 3.6 DockerイメージのビルドとCracklingPlusPlusの実行

```bash
# ビルドスクリプトを実行
./scripts/CracklingPlusPlus_build.sh

# CracklingPlusPlusコンテナを起動
docker run -it --rm -v $(pwd):/data crackling-plus-plus:latest
```

### 3.7 コンテナ内でのCracklingPlusPlusの動作確認

コンテナが起動したら、以下のコマンドで動作確認を行います：

```bash
# コンテナ内でCracklingPlusPlusコマンドの確認
CracklingPlusPlus -h

# ISSLCreateIndexコマンドの確認
ISSLCreateIndex

# ExtractOfftargetsコマンドの確認
ExtractOfftargets
```

### 3.8 変更のコミットとリモートリポジトリへのプッシュ

```bash
# 変更をステージングエリアに追加
git add dockerfiles/CracklingPlusPlus_dockerfile scripts/CracklingPlusPlus_build.sh

# 変更をコミット
git commit -m "Add Docker implementation for CracklingPlusPlus"

# リモートリポジトリにプッシュ
git push -u origin CracklingPlusPlus_docker
```

## 4. CracklingPlusPlusのDocker化でのベストプラクティス

### 4.1 依存関係の把握とDockerfileへの反映

CracklingPlusPlusのDocker化では、以下の依存関係を分析して対応しました：

1. **ビルドツール**：
   - build-essential
   - cmake
   - git

2. **ライブラリ依存関係**：
   - libboost-all-dev
   - bowtie2

3. **特殊パッケージ**：
   - ViennaRNA（重要な依存関係）

### 4.2 エラーハンドリングの実装

CracklingPlusPlusのViennaRNAパッケージインストールで実装した冗長化戦略：

```dockerfile
# ViennaRNAパッケージのインストール - 方法1: パッケージマネージャ
RUN apt-get update && \
    apt-get install -y vienna-rna || \
    (echo "Vienna RNA package not found in repositories, trying alternative installation..." && \
    # 方法2: ソースからのインストール
    cd /tmp && \
    wget https://www.tbi.univie.ac.at/RNA/download/sourcecode/2_5_x/ViennaRNA-2.5.0.tar.gz && \
    # 以下インストール手順
    )
```

このパターンでは：
1. まずパッケージマネージャによるインストールを試み
2. 失敗した場合は自動的にソースからのビルドに切り替え

これにより、様々な環境での再現性を高めています。

### 4.3 マルチステージビルドの活用

さらに効率的なイメージを構築するためのマルチステージビルドの例：

```dockerfile
# ビルドステージ
FROM ubuntu:22.04 AS builder

# ビルドに必要なパッケージのインストール
RUN apt-get update && apt-get install -y build-essential cmake git libboost-all-dev
WORKDIR /build
RUN git clone https://github.com/bmds-lab/CracklingPlusPlus.git
WORKDIR /build/CracklingPlusPlus
RUN mkdir build && cd build && cmake .. && make -j$(nproc)

# 実行ステージ
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y libboost-all-dev bowtie2 vienna-rna
WORKDIR /app
COPY --from=builder /build/CracklingPlusPlus/build/CracklingPlusPlus /app/
COPY --from=builder /build/CracklingPlusPlus/build/ISSLCreateIndex /app/
COPY --from=builder /build/CracklingPlusPlus/build/ExtractOfftargets /app/
```

### 4.4 ボリュームマウント戦略

CracklingPlusPlusでの効率的なデータ処理のためのマウント戦略：

```bash
# ホストの現在のディレクトリを/dataにマウント
docker run -it --rm -v $(pwd):/data crackling-plus-plus:latest

# 特定のゲノムデータディレクトリをマウント
docker run -it --rm -v /path/to/genomes:/genomes -v $(pwd):/data crackling-plus-plus:latest
```

### 4.5 ビルドパイプラインの自動化

CI/CDパイプラインでのCracklingPlusPlusのビルド自動化例：

```yaml
# .github/workflows/docker-build.yml
name: Docker Build

on:
  push:
    branches: [ main, develop, CracklingPlusPlus_docker ]
    paths:
      - 'dockerfiles/CracklingPlusPlus_dockerfile'
      - 'scripts/CracklingPlusPlus_build.sh'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build Docker image
        run: ./scripts/CracklingPlusPlus_build.sh
      - name: Test basic functionality
        run: |
          docker run --rm crackling-plus-plus:latest CracklingPlusPlus -h
          docker run --rm crackling-plus-plus:latest ISSLCreateIndex
```

## 5. トラブルシューティング

### 5.1 CracklingPlusPlusビルド時の一般的な問題と解決策

| 問題 | 原因 | 解決策 |
|------|------|--------|
| `vienna-rna`パッケージが見つからない | パッケージ名の違い | パッケージ名を`vienna-rna`に修正、またはソースからインストール |
| Boost関連のビルドエラー | ライブラリが見つからない | `libboost-all-dev`を明示的にインストール |
| CMakeのエラー | 最小バージョン要件 | 最新バージョンのCMakeをインストール |

実際に発生したエラーの例：
```
E: Unable to locate package viennarna
```

解決策として実装した方法：
1. パッケージ名を`vienna-rna`に修正
2. パッケージが見つからない場合の代替インストールパスを追加

### 5.2 Dockerコンテナでの実行時のトラブルシューティング

CracklingPlusPlusの実行時に発生する可能性のある問題：

1. **ファイルが見つからないエラー**：
   ```
   Could not find input file: /sample/genome.fna
   ```
   解決策：コンテナ内の正しいパスにファイルがあるか確認するか、ボリュームマウントを使ってホストからファイルを提供

2. **メモリ不足エラー**：
   解決策：Dockerに割り当てるメモリを増やす
   ```bash
   docker run -it --rm --memory=8g -v $(pwd):/data crackling-plus-plus:latest
   ```

## 6. 補足情報

### 6.1 GitHubユーザー名の修正

コミット履歴がローカルユーザー名になってしまった場合の修正手順：

```bash
# GitHubユーザー名とメールアドレスを設定
git config --global user.name "YOUR_GITHUB_USERNAME"
git config --global user.email "YOUR_GITHUB_EMAIL"

# 最後のコミットの著者情報を更新
git commit --amend --reset-author --no-edit

# 強制プッシュ
git push -f origin CracklingPlusPlus_docker
```

### 6.2 Docker環境のクリーンアップ

Docker使用時のディスク容量管理：

```bash
# 未使用のイメージを削除
docker image prune -a

# 停止したコンテナを削除
docker container prune

# 全てのDockerリソースをクリーンアップ
docker system prune
```

## 7. まとめ

CracklingPlusPlusのDocker化の例を通して、バイオインフォマティクスツールの効率的なコンテナ化方法を示しました。特に以下のポイントが重要です：

1. **依存関係の適切な管理**: 必要なライブラリとツールを正確に把握し、冗長化戦略を実装
2. **エラーハンドリングの充実**: インストールの代替パスを提供
3. **効率的なビルドプロセス**: ビルドスクリプトの自動化
4. **データのマウント戦略**: ホストとコンテナ間のデータ共有
5. **バージョン管理との統合**: GitとDockerの効果的な組み合わせ

これらの原則に従うことで、他のバイオインフォマティクスツールのDocker化も効率的に行うことができます。

---

*このドキュメントは、実際のCracklingPlusPlusのDocker化作業に基づいて作成されました。環境やツールのバージョンによって詳細が異なる場合があります。*
