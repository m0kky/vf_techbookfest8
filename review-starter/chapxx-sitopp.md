# M5StickCで赤外線リモコンを作り、AlexaやGoogle Homeから家電を操作する。

本章では、Google HomeからActions On Googleを呼び出し、ActionsからMQTTでM5Stackへメッセージを渡し、M5Stackから赤外線で家電を操作する方法を説明します。

![アーキテクチャ](images/chapxx-sitopp/s000.png)


M5Stackを赤外線リモコン化するところでC++のコードを書きますが、それ以外はノンコーディングで出来ます。
またお手軽路線を守るため、VoiceflowやMQTTやWebhooksなどのサーバーサイドは、全て無料のものを使いました。
IoTに使えるいろんなテクを寄せ集めていますので、何かのヒントになると幸いです。

<!-- Actions On Googleを作る部分でVoiceflowを使っていますので、アップロード先を変えればAlexaでも使えるところが良いですね。


Nature Remo Miniなどのスマートハブは便利ですが、買うと結構高いので、家にあったM5Stackを使って自作してみます。M5Stack用の赤外線送受信ユニット（308円）だけは買い足しました。

最初、格安で人気のM5StickCを使って検証してみたのですが、赤外線の送信部分の出力が弱く、50cmくらいまで近づけないと反応しなかったので、M5Stackに変更しました。こちらなら1.5mほど飛びますので、一応使える物になると思います。 -->


### 本章でやること

* M5Stackで赤外線リモコン作成
* AdafruitのMQTTブローカの設定
* IFTTTでMQTTの簡易パブリッシャーを作る
* VoiceflowでActions On Googleを作成
* 全部をつなげて動作確認

<!-- * おまけ、VoiveflowからM5StickCを走らせる -->


### 使用した部品

<!-- * * M5StickC ¥1980 -->
* M5STACK-BASIC ¥3,575　
* M5用、赤外線送受信ユニット ¥308

注1　MacとM5Stackをつなぐ時、M5Stackに付属のUSB Type-Cケーブルを使わないと認識しないことが多いので、なくさないよう大切に保管しておきましょう。


### 開発環境

* MacBook Air（OS: 10.13.6 High Sierra）
* VSCode
* Arduino IDE 1.8.9
* Google Home mini


## 手順

## 1. M5Stackで赤外線リモコン作成

<!-- あらかじめ、Arduino IDEでM5StickCを使えるようにしておきます。 -->
あらかじめ、Arduino IDEでM5Stackを使えるようにしておきます。

参考：https://〜


### 赤外線の命令を拾う

* Arduino IDEを起動し、M5StackをMacにUSB Type-Cケーブルで接続します。

* Arduino IDEの「ツール」→「ライブラリを管理」→「IRremoteESP8266」と入力し、表示されたライブラリをインストールします。

* 「ファイル」→「スケッチ例」→「IRremoteESP8266」→「IRrecvDumpV2」を開きます。

* 「ファイル」→「新規ファイル」でスケッチエディタを開き、上で開いた「IRrecvDumpV2」を全文コピーして貼り付け、以下の一行だけ書き換えます。

```
const uint16_t kRecvPin = 14;
↓
const uint16_t kRecvPin = 22;
```

※M5STickCでやる場合は、ここを「const uint16_t kRecvPin = 33;」としてください。

* ツール→ボード→「M5Stack-Core-ESP32」を選択しておきます。

* ツール→シリアルポート→「〜USB〜」のものを選択します。

「→」をクリックして、M5Stackに書き込みします。

```
Leaving...
Hard resetting via RTS pin...
```
というメッセージが出てプロンプトが止まったら、M5Stackの画面には何も出ませんが、インストールは完了しています。

ツール→シリアルモニタを開きます。ここでシリアル出力したメッセージが閲覧できるようになります。
「IRrecvDumpV2 is now running and waiting for IR input on Pin 22」というメッセージが出ていたら、ちゃんとシリアル出力できています。

では、エアコンなどのリモコンを構えて、赤外線ユニットの20〜30センチ以内でリモコンを操作してみましょう。

オンとオフの2回、操作したところです。
ここに画像：s021.png。


シリアルモニタにコードが出力されたら、全文コピーして、メモ帳などに保存しておきます。


### 赤外線命令の切り出し

メーカごとにやり方が違うので、少し面倒です。
この本ではDaikinのエアコンでのやり方について説明します。


Arduino IDEの「ファイル」→「スケッチ例」→「IRremoteESP8266」→「IRsendDemo」を開きます。

「ファイル」→「新規ファイル」でスケッチエディタを開き、上で開いた「IRsendDemo」を全文コピーして貼り付け、以下を書き換えます。

```
const uint16_t kIrLed = 4;
↓
const uint16_t kIrLed = 21;

```


### MQTTのサブスクライバ

knolleary/pubsubclient を取り込みます。

https://github.com/knolleary/pubsubclient
から clone or Downloadボタンを押してダウンロードします。

スケッチ→ライブラリをインクルード→.zip形式のライブラリをインストール。



## 2. AdafruitのMQTTブローカの設定

### AdafruitでMQTTブローカーの登録

Adafruit（エイダフルート）でアカウントを作成。

https://ifttt.com/adafruit

ダッシュボードを作成。
https://io.adafruit.com/
にアクセスし、＞Actions＞Create a New Dashboard＞
Name：M5 Devなど、任意の名前
Description：開発用など、任意の説明
＞create

Feeds＞ View All＞ Actions＞ Create a new feed＞

Name：sitoppM5Dev
Description：開発用です

出来上がった「sitoppM5Dev」をクリックすると、ダッシュボードがひらく。


AdafruitのMQTT情報はこちら
https://io.adafruit.com/api/docs/mqtt.html#mqtt-connection-details



### IFTTTでWebhooksとMQTTを繋げる





「Connect」をクリックすると、Adfruitのサイトに飛ぶので、ログインしてなければログインしてから、Authorizeをクリック。

右上のユーザーメニュー＞「Create」＞「This」＞Search serviceの記入欄に「Webhooks」と入力してエンター＞Webhooksのパネルをクリック＞「Receive a web requesbt」のパネルをクリック＞ 「Event name」に好きな名前を入力。「M5_MQTT」など。＞「Create trigger」

次に「That」をクリック＞Search serviceの記入欄に「Adafruit」と入力してエンター＞Send data to Adafruit IO＞
Feed name：選択不可

Data to save ：右下の「Add Ingredient」」をクリックし、「EventName」を選択＞
Create action


## VoiceflowでAlexa Skill / Actions On Googleを作成

Integrationsブロック

Request URL
put : https://io.adafruit.com/sitopp/feeds/onoff

Headers: 
Content-Type
Value: application/json


Body:
「Raw」を選択して、
{
  "value1":"aircon",
  "value2":"on",
  "value3":"t7d=ClVt"
}


## Google HomeからM5StickへMQTTでメッセージ送信
## 導通確認



{ 
  "value1" : "aircon", 
  "value2" : "on", 
  "value3" : "t7d=ClVt" 
}


