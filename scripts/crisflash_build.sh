#!/bin/bash

# スクリプトが存在するディレクトリを取得
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# リポジトリのルートディレクトリを取得
REPO_ROOT="$( cd "$SCRIPT_DIR/.." &> /dev/null && pwd )"

# Dockerfileのパス
DOCKERFILE_PATH="$REPO_ROOT/dockerfiles/crisflash_dockerfile"

# イメージ名とタグ
IMAGE_NAME="crisflash"
TAG="latest"

echo "==================================================="
echo "crisflash Dockerイメージのビルドを開始します"
echo "==================================================="
echo "Dockerfileのパス: $DOCKERFILE_PATH"
echo "イメージ名: $IMAGE_NAME:$TAG"
echo "==================================================="

# Dockerビルドチェックの実行
echo "Dockerビルドチェックを実行中..."
docker build . --check -f "$DOCKERFILE_PATH"

# ビルドチェックの確認
if [ $? -eq 0 ]; then
    echo "==================================================="
    echo "ビルドチェックが成功しました！"
    echo "フルビルドを実行します..."
    echo "==================================================="
else
    echo "==================================================="
    echo "ビルドチェックで問題が見つかりました。"
    echo "上記の警告を確認し、Dockerfileを修正してください。"
    echo "それでもビルドを続行しますか？ (y/n)"
    read answer
    if [ "$answer" != "y" ]; then
        echo "ビルドを中止します。"
        exit 1
    fi
    echo "警告を無視してビルドを続行します。"
    echo "==================================================="
fi

# Dockerイメージのビルド
docker build -t "$IMAGE_NAME:$TAG" -f "$DOCKERFILE_PATH" .

# ビルド結果の確認
if [ $? -eq 0 ]; then
    echo "==================================================="
    echo "ビルドが成功しました！"
    echo "イメージ情報:"
    docker images | grep "$IMAGE_NAME"
    echo ""
    echo "crisflashを実行するには以下のコマンドを使用してください："
    echo "docker run -it --rm -v \$(pwd):/data $IMAGE_NAME:$TAG"
    echo "または特定のコマンドを実行する場合："
    echo "docker run -it --rm -v \$(pwd):/data $IMAGE_NAME:$TAG crisflash -g genome.fa -s candidate_sequence.fa -o results.bed -m 5"
    echo "==================================================="
else
    echo "==================================================="
    echo "ビルドに失敗しました。"
    echo "上記のエラーメッセージを確認してください。"
    echo "==================================================="
fi
