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
