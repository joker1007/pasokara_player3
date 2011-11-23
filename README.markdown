PasokaraPlayer
===================

持ち込みカラオケを支援するための、曲予約・自動再生システム。
ニコニコ動画にアップされているニコカラ動画を利用することを前提にしています。
サーバ側に保存してある動画ファイルをwebm・mp4にエンコードして、
予約順に自動再生を行います。


使い方概要
---------------

### 予約側:

1. iPhone, Android等のスマートフォンからサーバにアクセスし、ログインする。
1. 再生したい曲を検索する。
1. 曲のタイトルをタップし、曲を予約する。

### 再生側:

1. 再生用ノートPCをカラオケ機等に接続しておく。 (各カラオケ機を経由してどうやって映像・音声を出力するかは後述する。)
1. ブラウザを開き、プレーヤーページを表示する。
1. 予約があればvideoタグが表示され自動で再生が開始される。

### 動画ファイルのエンコードについて
ブラウザから自動再生を行うため、動画ファイルをhtml5で利用可能な形式にエンコードする。
エンコードが実施されるのは以下のタイミング。

* 予約登録がされた時
* プレビューページが表示された時
* 予約曲の再生が開始される時

これらのタイミングで、エンコード済みのファイルが存在していない場合、
エンコードジョブが登録され、バックグラウンドでエンコードが実施される。

インストール
------------------

### 依存するソフトウェア
* MongoDB
* Redis
* ffmpeg (以下のcodecが利用可能であること)
    * libx264
    * libvpx
    * libvorbis
    * libfaac
    * webm
* Apache Solr

     (gemにより自動でインストールされるが、バージョンが古いため別途用意しても良い)


### コマンド
``` sh
git clone git://github.com/joker1007/pasokara_player3.git
cd pasokara_player3
bundle install --path vendor/bundle
cp config/mongoid.yml.example config/mongoid.yml
cp config/pasokara_player.yml.example config/pasokara_player.yml
cp config/resque.yml.example config/resque.yml
cp config/sunspot.yml.example config/sunspot.yml
cp config/unicorn.rb.example config/unicorn.rb
cp config/cucumber.yml.example config/cucumber.yml.example
```

pasokara_player.ymlには以下の内容を設定する必要があります。

* root_dir: 動画ファイルの存在するディレクトリ。root_dir以下のディレクトリを検索対象とする。
* download_dir: 動画ファイルのダウンロード先になるディレクトリ。root_dir以下のディレクトリに設定しておく。
* url_list: ニコニコ動画の検索ページ等のRSSを示すURLのリスト。このリストを元に動画をダウンロードする。


### 起動
```sh
bundle exec unicorn_rails
```

http://localhost:7000/にアクセスする。

Rakeタスク
--------------------------

### ダウンロードの実行

以下のコマンドを一度実行する。

```sh
bundle exec rails runner "Util::NicoDownloader.new"
```

ニコニコ動画のログイン情報を入力すると、
ホームディレクトリ以下の.pit/にログイン情報が保存される。
ログイン情報保存後は、以下のコマンドでダウンロードが開始される。

```sh
bundle exec rake niconico:download
```

注: 現在、ダウンロードスクリプトはメモリを大量に消費する問題があります。
動作環境次第では、メモリを食い潰す可能性があるので、注意してください。


### 動画情報の読み込み
ダウンロードしたファイルは自動的にデータベースに登録されるが、
途中で異常終了した場合や、自分で配置したファイルを登録したい場合は、
以下のコマンドを利用する。

```sh
bundle exec rake pasokara:load
```


### エンコード状況のクリア
データベース内に、動画ファイルがエンコード中かどうかを保持しているが、
エンコードジョブが異常終了した場合、
ステータスが更新されないまま保持される可能性があるため、
それを一括でクリアするタスクがある。
(エンコード済のファイルは削除されない)

```sh
bundle exec rake pasokara:encoding_clear
```


ライセンス
-------------------

* Copyright (c) 2011 Tomohiro Hashidate
* MIT licenses:
* http://www.opensource.org/licenses/mit-license.php
