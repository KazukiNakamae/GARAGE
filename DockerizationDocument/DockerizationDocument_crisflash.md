# crisflash ツールのDocker化手順書

このドキュメントでは、crisflashツールをDocker化し、GARAGEリポジトリに追加する一連の手順を詳細に説明します。初学者でも理解しやすいよう、各ステップに詳細な説明とコマンドを記載しています。

## 目次

1. [リポジトリのクローン](#1-リポジトリのクローン)
2. [ブランチの作成](#2-ブランチの作成)
3. [Dockerfileの作成](#3-dockerfileの作成)
4. [ビルドスクリプトの作成](#4-ビルドスクリプトの作成)
5. [変更をコミットおよびプッシュ](#5-変更をコミットおよびプッシュ)
6. [Dockerイメージのビルド](#6-dockerイメージのビルド)
7. [Docker環境のテスト](#7-docker環境のテスト)
8. [プルリクエストの作成](#8-プルリクエストの作成)

## 1. リポジトリのクローン

まず、GARAGEリポジトリとcrisflashリポジトリの両方をクローンします。これにより、Docker化対象のツールと、Docker設定ファイルを追加するリポジトリの両方にアクセスできるようになります。

```bash
# 作業用ディレクトリを作成
mkdir -p ~/Desktop/biodxthon2502-2
cd ~/Desktop/biodxthon2502-2

# GARAGEリポジトリのクローン
git clone https://github.com/KazukiNakamae/GARAGE.git

# crisflashリポジトリのクローン
git clone https://github.com/crisflash/crisflash.git
```

## 2. ブランチの作成

GARAGEリポジトリ内で新しいブランチを作成します。ブランチ名は、Docker化するツールの名前を含むものにします。

```bash
# GARAGEリポジトリに移動
cd GARAGE

# 新しいブランチを作成し、チェックアウト
git checkout -b crisflash_docker
```

## 3. Dockerfileの作成

GARAGEリポジトリの`dockerfiles`ディレクトリ内に、`crisflash_dockerfile`というファイルを作成します。このファイルには、crisflashツールをビルドして実行できるDockerイメージの構築手順を記述します。

```bash
# dockerfilesディレクトリに移動（存在しない場合は作成）
mkdir -p dockerfiles
```

以下の内容で`dockerfiles/crisflash_dockerfile`を作成します：

```dockerfile
# syntax=docker/dockerfile:1
# check=error=true

# ベースイメージを指定
FROM ubuntu:22.04

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    make \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリを設定
WORKDIR /app

# crisflashのソースコードをクローン
RUN git clone https://github.com/crisflash/crisflash.git

# crisflashのビルド
WORKDIR /app/crisflash
RUN make

# バイナリをPATHに追加
ENV PATH="/app/crisflash/bin:${PATH}"

# サンプルデータ用のディレクトリを作成
RUN mkdir -p /data

# 作業ディレクトリを/dataに変更
WORKDIR /data

# ヘルプを表示するコマンドをデフォルトで実行
CMD ["crisflash", "-h"]
```

## 4. ビルドスクリプトの作成

GARAGEリポジトリの`scripts`ディレクトリ内に、`crisflash_build.sh`というシェルスクリプトを作成します。このスクリプトは、Dockerイメージのビルドを自動化し、エラーチェックも行います。

```bash
# scriptsディレクトリに移動（存在しない場合は作成）
mkdir -p scripts
```

以下の内容で`scripts/crisflash_build.sh`を作成します：

```bash
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
```

ビルドスクリプトに実行権限を付与します：

```bash
chmod +x scripts/crisflash_build.sh
```

## 5. 変更をコミットおよびプッシュ

作成したファイルをGitにコミットし、リモートリポジトリにプッシュします。

```bash
# 変更をステージング
git add dockerfiles/crisflash_dockerfile scripts/crisflash_build.sh

# 変更をコミット
git commit -m "Add Docker implementation for crisflash"

# リモートリポジトリにプッシュ
git push -u origin crisflash_docker
```

## 6. Dockerイメージのビルド

作成したビルドスクリプトを実行して、Dockerイメージをビルドします。

```bash
# GARAGEリポジトリのルートディレクトリで実行
./scripts/crisflash_build.sh
```

ビルドプロセスは以下のステップで進行します：

1. Dockerビルドチェックの実行
2. 問題がなければフルビルドを実行
3. ビルド結果の確認とイメージ情報の表示

ビルドが成功すると、以下のようなメッセージが表示されます：

```
===================================================
ビルドが成功しました！
イメージ情報:
crisflash                      latest    091e2317a41e   1 second ago        361MB

crisflashを実行するには以下のコマンドを使用してください：
docker run -it --rm -v $(pwd):/data crisflash:latest
または特定のコマンドを実行する場合：
docker run -it --rm -v $(pwd):/data crisflash:latest crisflash -g genome.fa -s candidate_sequence.fa -o results.bed -m 5
===================================================
```

## 7. Docker環境のテスト

ビルドしたDockerイメージが正しく機能するかテストします。

### ヘルプコマンドのテスト

```bash
docker run -it --rm crisflash:latest
```

このコマンドを実行すると、crisflashのヘルプメッセージが表示されます：

```
Program: crisflash (A tool for CRISPR/Cas9 sgRNA design and off-target identification)
Version: 1.2.0

Usage:   crisflash -g <genome.fa> -s <input.fa> -o <o> [options]

Options:
          -g FILE	FASTA format reference genome.
          -s FILE	FASTA file containing candidate sequence.
          -p PAM	PAM sequence. Default: NGG
          -V FILE	phased VCF file.
          -B		 save output in BED format, with sequence provided on comment field and off-target score on score field. (Default)
          -C		 save output in cas-offinder format.
          -A		 save output in cas-offinder format, with additional column reporting variant and haplotype info.
          -o FILE	output file name saved in BED format.
          -m INT	Number of mismatches allowed. Default: 2.
          -t INT	Number of threads for off-target scoring. Default: 1.
          -u	Exclude low complexity genomic sequences marked lowercase in soft masked genomes.
          -h	Print help.
          -v	Print version.

Examples: crisflash -g genome.fa -s candidate_area.fa -o validated_gRNAs.bed -m 5
          crisflash -g genome.fa -s candidate_area.fa -o validated_gRNAs.bed -m 5 -C
          crisflash -g genome.fa -V phased_variants.vcf -s candidate_area.fa -o validated_gRNAs.bed
          crisflash -g genome.fa -o all_unscored_gRNAs.bed
          crisflash -s candidate_area.fa -o all_unscored_gRNAs.bed
```

### バージョン情報の確認

```bash
docker run -it --rm crisflash:latest crisflash -v
```

出力：
```
crisflash 1.2.0
```

### バイナリの配置確認

```bash
docker run -it --rm crisflash:latest sh -c "which crisflash && ls -la /app/crisflash/bin"
```

出力：
```
/app/crisflash/bin/crisflash
total 132
drwxr-xr-x 1 root root    42 Feb 27 14:50 .
drwxr-xr-x 1 root root     6 Feb 27 14:50 ..
-rwxr-xr-x 1 root root 68112 Feb 27 14:50 crisflash
-rwxr-xr-x 1 root root 63808 Feb 27 14:50 crisflashVcf
```

## 8. プルリクエストの作成

コードの変更をGitHubにプッシュした後、WebブラウザでGARAGEリポジトリにアクセスし、プルリクエストを作成します。

1. GARAGEリポジトリのGitHubページに移動します：https://github.com/KazukiNakamae/GARAGE
2. 「Pull requests」タブをクリックします
3. 「New pull request」ボタンをクリックします
4. 比較するブランチとして「crisflash_docker」を選択します
5. 「Create pull request」ボタンをクリックします
6. タイトルと説明を入力します
   - タイトル例：「Add Docker implementation for crisflash」
   - 説明例：「crisflashツールのDocker化を実装しました。dockerfilesディレクトリにDockerfileを、scriptsディレクトリにビルドスクリプトを追加しています。」
7. 再度「Create pull request」ボタンをクリックして送信します

## まとめ

以上の手順で、crisflashツールのDocker化に成功しました。作成したDockerfileとビルドスクリプトにより、他のユーザーも簡単にcrisflashツールを利用できるようになります。DockerイメージはUbuntu 22.04をベースに、必要なビルドツールと依存関係を含み、crisflashの実行環境を完全に再現しています。

### 主なメリット

1. **環境の再現性**: どのシステムでも同じ環境でcrisflashを実行できます
2. **依存関係の管理**: 必要なライブラリやツールがDockerイメージに含まれているため、インストールの手間が省けます
3. **バージョン管理**: 特定のバージョンのcrisflashを固定して使用できます
4. **データの共有**: ホストとコンテナ間でデータをマウントして共有できます

### 使用例

```bash
# ホストの現在のディレクトリをコンテナの/dataにマウントして実行
docker run -it --rm -v $(pwd):/data crisflash:latest crisflash -g genome.fa -s candidate_sequence.fa -o results.bed -m 5
```

これにより、現在のディレクトリ内のファイルにアクセスしながらcrisflashを実行できます。
