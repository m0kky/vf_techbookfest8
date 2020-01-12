# スマートリモコンをM5StickCで自作し、Google Homeから家電を操作

## 概要

本章は、**M5StickCや電子工作に興味ある人に、「音声で操作するインタフェース」が「実はお手軽に追加できる」事を知ってもらいたくて書きました。**
VUIクラスタの人にも**軽率に電子工作沼にハマっていただきたい**ので、半田付けなどしなくても使えるケース付きの格安小型マイコンを使っております。

音声部分の開発にVoiceflowを使っており、アップロード先を変えればAmazon Echoにも対応できます。

IoTのプロトタイピングにも使えるいろんなテクを寄せ集めていますので、何かのヒントになると幸いです。

### やること

* 1. M5StickCで自宅エアコンの赤外線リモコンを作成 
* 2. AdafruitのMQTTブローカの設定 
* 3. IFTTTでMQTTの簡易パブリッシャーを作る 
* 4. VoiceflowでActions On Googleを作成 
* 5. M5StickCリモコンをMQTT対応にする
* 6. 全部をつなげて動作確認



![アーキテクチャ](images/chapxx-sitopp/s001.jpg)

### 開発環境

* MacBook Air（OS: 10.13.6 High Sierra）
* VSCode
* Arduino IDE 1.8.9
* Google Home mini

自分はMacを使いましたが、Windowsにも共通のツールがあります。適宜読み替えて進めてください。

### 使用した部品

* M5StickC ¥1,980　
* M5用、赤外線送受信ユニット ¥308
@<fn>{sitopp_plice}

//footnote[sitopp_plice][値段は2020年1月12日時点でのスイッチサイエンスの通販税込価格です。]

![使用した部品](images/chapxx-sitopp/s002.jpg)

//embed[latex]{
\clearpage
//}


## M5StickCで赤外線リモコン作成

あらかじめ、MacにArduino IDEをインストールして、M5StickCを使えるようにしておきます。

参考）

* 公式「M5StickCクイックスタート-Arduino Win」
https://docs.m5stack.com/#/ja/quick_start/m5stickc/m5stickc_quick_start_with_arduino_Windows

* 「くらつきねっと」さんの「M5StickC で開発を行うための Arduino IDE のセットアップ」
https://kuratsuki.net/2019/07/


### M5StickCで、赤外線リモコンの命令を読み込む

Mac上でArduino IDEを起動し、M5StickCをMacにUSB Type-Cケーブルで接続します。

* 「ツール」→「ボード」→「M5StickC」を選択します。
* 「ツール」→「シリアルポート」→表示された複数の選択肢の中から、「/dev/cu.usbserial-」の文字が入っているものを選択します。

![Arduino IDEのツールメニュー、M5StickCがシリアルポート接続できた状態](images/chapxx-sitopp/s003.jpg)


* Arduino IDEの「ツール」→「ライブラリを管理」→「IRremoteESP8266」と入力し、表示されたライブラリをインストールします。
* 「ファイル」→「スケッチ例」→「IRremoteESP8266」→「IRrecvDumpV2」を開きます。
* 「ファイル」→「新規ファイル」でスケッチエディタを開きます。下敷き表示されたコードは削除してください。
* 上で開いた「IRrecvDumpV2」を全文コピーして貼り付け、以下の一行だけ書き換えます。

```
const uint16_t kRecvPin = 14;
↓
const uint16_t kRecvPin = 33;
```

* スケッチエディタの左上にある「→」アイコンをクリックして、M5StickCに書き込みします。
* 保存場所を聞かれるので、適当に指定します。
* 書き込みにかかる時間、数十秒を待ちます。
* スケッチエディタの下半分にインストールログがどどっと出力されます。以下のようなメッセージが出たらインストール完了です。

```
Writing at 0x00008000... (100 %)
Wrote 3072 bytes (128 compressed) at 0x00008000 in 0.0 seconds 
Hash of data verified.

Leaving...
Hard resetting via RTS pin...
```

* 「ツール」→「シリアルモニタ」をクリックして、窓を開きます。
* 「自動スクロール」にチェックが入っている事を確認しましょう。
* 「IRrecvDumpV2 is now running and waiting for IR input on Pin 33」というメッセージが出るはずです。

* M5StickCに置き換えたい家電のリモコンを持ってきてください。
* 赤外線ユニットの20〜30センチ以内でリモコンを操作してください。
* シリアルモニタにコードが出力されます。

![リモコン](images/chapxx-sitopp/s021.jpg)

例）Daikinのエアコン（古すぎて型番不明）
オフとオンを一回づつ押したところ

```
21:39:17.721 -> Timestamp : 000130.976
21:39:17.721 -> Library   : v2.7.1
21:39:17.721 -> 
21:39:17.721 -> Protocol  : DAIKIN
21:39:17.721 -> Code      : 0x11DA2700C50000D711DA270042000054（以下略）
21:39:17.721 -> Mesg Desc.: Power: Off, Mode: 4 (Heat), Temp: （以下略）
21:39:17.792 -> uint16_t rawData[583] = {492, 396, （略）466};  // DAIKIN
21:39:18.076 -> uint8_t state[35] = {0x11, 0xDA, 0x27, 0x00,（略）0x76};
21:39:18.076 -> 
21:39:18.076 -> 
21:39:34.883 -> Timestamp : 000148.122
21:39:34.883 -> Library   : v2.7.1
21:39:34.883 -> 
21:39:34.883 -> Protocol  : DAIKIN
21:39:34.883 -> Code      : 0x11DA2700C50000D711DA270042000054（以下略）
21:39:34.883 -> Mesg Desc.: Power: On, Mode: 4 (Heat), Temp:  （以下略）
21:39:34.945 -> uint16_t rawData[583] = {510, 374,（略）494};  // DAIKIN
21:39:35.211 -> uint8_t state[35] = {0x11, 0xDA, 0x27, 0x00,（略）0x77};
21:39:35.248 -> 
```

* このログを全文コピーして、メモ帳などに保存しておきます。

### 赤外線リモコンの命令パターンの抽出

赤外線リモコンの命令はメーカー間で統一されておらず、にフォーマットが違います。
この本ではDaikinのエアコンのやり方について説明します。
（他のメーカーについては、ググるといろいろ親切に解説してくださっているページがありますので、後ほど参考リンクを記載します。）

* Arduino IDEの「ツール」→「ライブラリをインクルード」→「ライブラリを管理」→「IRsend」と入力し、表示されたライブラリをインストールします。
* 以下のURLに、私が書いたDaikinの赤外線リモコンを送信するコードが置いてありますので、アクセスしてください。
※404エラーが出た場合はGithubにログインしてからもう一度開いてください。（アカウントがない場合はまずは作ってからログインを。） 


URL：https://github.com/sitopp/voiceflow_mqtt_M5StickC_IRremo-con/

ファイルパス：M5StickC/IRsendDemo_DAIKIN.ino
<!-- 
```
#include <M5StickC.h>
#include <IRremoteESP8266.h>
#include <IRsend.h>

const uint16_t kIrLed = 32;  
IRsend irsend(kIrLed);  

void setup() {
    irsend.begin();
}
（以下略）
``` -->


* Arduino IDEの「ファイル」→「新規ファイル」でスケッチエディタを開きます。下敷き表示されたコードは削除してください。
* IRsendDemo_DAIKIN.inoの全文をスケッチエディタに貼り付けてください。
* スケッチエディタ上で、赤外線のパターンを書き換えましょう。

例）
Daikinの場合、
「uint8_t daikin_code[35]={}」の中身を、先ほど採取した赤外線のパターンの「uint8_t state[35] ={}」の中身で上書きをします。

![From](images/chapxx-sitopp/s024)
↓上書きする
![To](images/chapxx-sitopp/s025)


* スケッチエディタの左上にある「→」アイコンをクリックして、M5StickCに書き込みします。
* ファイルの保存場所を聞かれるので、適当に指定します。
* 書き込みにかかる時間、数十秒を待ちます。
* スケッチエディタの下半分にインストールログがどどっと出力され、「Hard resetting via RTS pin...」メッセージが出たらインストール完了です。
* USBケーブルを抜いて、M5StickCをエアコンの50cn以内に持って行きます。赤外線送受信ユニットは抜かずにさしたままです。M5ボタンを押すと、エアコンがつきました。

![M5StickCでエアコンを操作しているところ](images/chapxx-sitopp/s023.jpg)




**他のメーカーの場合**

ありがたい事に、IRremoteESP8266ライブラリの作者のGithubにサンプルコードがあります。

https://github.com/crankyoldgit/IRremoteESP8266

しかしこれだけでは良くわからないかもしれません。

2019年に、M5StickCで赤外線リモコンを作って技術ブログを書いた人が何人もいらっしゃったので、そちらを参考にすると、国内の主要メーカーのフォーマットはわかると思います。

参考にさせていただいた神ブログをいくつかご紹介します。

* NEC

M5StickCでスマホから操作できる家電リモコンを作る
https://elchika.com/article/218f5072-28a6-461c-a801-43390305f4cc/


* 各種テレビメーカー　

M5StickC を赤外線リモコンにする
https://kuratsuki.net/2019/07/




## 2. AdafruitのMQTTブローカの設定

* Adafruit（エイダフルート）https://io.adafruit.com/ にアクセスし、アカウントを作成します。
* 「Actions」 → 「Create a New Dashboard」で、ダッシュボードを作成します。

Name：voiceflowIRDev
Description：開発用

* 「Feeds」 → 「View All」 → 「Actions」 → 「Create a new feed」でFeedsを作成します。

Name：daikin_onoff
Description: Daikin 赤外線リモコン なりすまし用

* 「Feeds」 → 「View All」→ 「daikin_onoff」 → 「Feed Info」
「MQTT by Key」のところにMQTTのTopicが自動生成されていますので、メモ帳にコピーしておきます。

![MQTTのTopics](images/chapxx-sitopp/s027.jpg)


* MQTTブローカーのサーバー情報を調べておきます。

https://io.adafruit.com/api/docs/mqtt.html#mqtt-connection-details

Host	io.adafruit.com
Secure (SSL) Port	8883
Insecure Port	1883
**MQTT over Websocket	443
Username	Your Adafruit IO Username
Password	Your Adafruit IO Key

なおUsername/passwordは、「https://io.adafruit.com/」のユーザーアカウントではありません。
ダッシュボードの右肩にある「AIO Key」をクリックすると閲覧できますので、メモ帳などに控えておきましょう。




### 3. IFTTTでMQTTの簡易パブリッシャーを作る

webhooksで発行されたURLにアクセスすると、AdafruitのMQTTブローカーにTopicをパブリッシュするという仕組みを作ります。

* IFTTT（イフト）にログインします。 https://ifttt.com/
* 右上の人型アイコンをクリック → プルダウンメニューが表示されたら、「Create」 をクリック
* 「Create your own」画面で「This」をクリック
* 「Search services」という入力欄に「webhooks」と入力 → 表示された「Webhooks」のパネルをクリック
* 初めての人は、「Connect Webhooks」という画面が表示されるので、Connectをクリックする。 
* 「Receive a web request」のパネルをクリック→ Event Nameの設定画面で、文字を入力する

例）
Event Name：Daikin_OnOff

* 「Create trigger」→ 「That」をクリック →「Search services」という入力欄に「Adafruit」と入力
* 表示された「Adafruit」のパネルをクリック
* 初めての人は、「Connect Adafruit」という画面が表示されるので、Connectをクリックする。 ポップアップ画面で下スクロールし、
「Authorize IFTTT」の下にある「AUTHORIZE」をクリックする。
* 「Send data to Adafruit IO」のパネルをクリック
* 「Feed name」が選択肢になっていて、先ほどAdafruitで登録したFeed「daikin_onoff」が表示されているはずなので、選ぶ。
* 「Data to save」の右下にある「Add ingredient」をクリックし、EventNameをクリックする。
*  再度「Add ingredient」をクリックし、Value1、Value2、Value3もクリックする。「Data to save」は「{{EventName}} {{Value1}} {{Value2}} {{Value3}}」となる。
* 「Create action」→「Finish」

完成後、右上の「settings」をクリックするとIFTTTレシピの詳細が見れます。

![IFTTTのレシピ詳細](images/chapxx-sitopp/s026)

### WebhooksのURLを調べる

* ChromeでIFTTTの「My Services」にアクセス https://ifttt.com/my_services 
* 「webhooks」 → 「Documentation」
* 「Make a POST or GET web request to:」の下にあるURLをコピーして、メモ帳などに控えておく。
* 「With an optional JSON body of:」の下にあるJsonをコピーして、メモ帳などに控えておく。

例）
URL：https://maker.ifttt.com/trigger//with/key/xxxxxxxxxxxxx_xxxxxxxxxxxxxx
JSON：{ "value1" : "", "value2" : "", "value3" : "" }

![webhooksのURL](images/chapxx-sitopp/s028)


## 4. VoiceflowでActions On Googleを作成


## 5. M5StickCリモコンをMQTT対応にする

