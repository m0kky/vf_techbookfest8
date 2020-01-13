# スマートリモコンをM5StickCで自作し、Google Homeから家電を操作

## 概要

本章は、M5StickCや電子工作クラスタの人に、「音声で操作するインタフェース」を追加するのは案外気軽にできる事を知ってもらいたくて書きました。VUIクラスタの人にも軽率に電子工作沼にハマっていただきたいので、半田付けなどしなくても使えるケース付きの格安小型マイコンを使っております。

IoTのプロトタイピングにも使えるいろんなテクを寄せ集めていますので、何かのヒントになりますと幸いです。

### やること

* M5StickCで赤外線リモコン作成 
* AdafruitのMQTTブローカの設定 
* IFTTTでMQTTの簡易パブリッシャーを作る 
* VoiceflowでActions On Googleを作成 
* M5StickCリモコンをMQTT対応にする
* 全部をつなげて動作確認



![アーキテクチャ](images/chapxx-sitopp/s001)

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

![使用した部品](images/chapxx-sitopp/s002)

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

![Arduino IDEのツールメニュー、M5StickCがシリアルポート接続できた状態](images/chapxx-sitopp/s003)


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

![リモコン](images/chapxx-sitopp/s021)

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

### 赤外線リモコンの命令パターンの抽出と、C++コードへの反映

赤外線リモコンの命令はメーカー間で統一されておらず、にフォーマットが違います。
この本ではDaikinのエアコンのやり方について説明します。
（他のメーカーについては、ググるといろいろ親切に解説してくださっているページがありますので、後ほど参考リンクを記載します。）

* Arduino IDEの「ツール」→「ライブラリをインクルード」→「ライブラリを管理」→「IRsend」と入力し、表示されたライブラリをインストールします。
* 以下のURLに、私が書いたDaikinの赤外線リモコンを送信するコードが置いてありますので、アクセスしてください。
※404エラーが出た場合はGithubにログインしてからもう一度開いてください。（アカウントがない場合はまずは作ってからログインを。） 


URL：https://github.com/sitopp/vf_techbookfest8_sampleCode

ファイルパス：M5StickC/IRsendDemo_DAIKIN.ino

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
``` 


* Arduino IDEの「ファイル」→「新規ファイル」でスケッチエディタを開きます。下敷き表示されたコードは削除してください。
* IRsendDemo_DAIKIN.inoの全文をスケッチエディタに貼り付けてください。
* スケッチエディタ上で、赤外線のパターンを書き換えます。

例）
Daikinの場合、「uint8_t daikin_code[35]={}」の中身を、先ほど採取した赤外線のパターンの「uint8_t state[35] ={}」の中身で上書きをします。35は配列の要素数ですので、数が違う場合はあわせて変更してください。


![コピー元](images/chapxx-sitopp/s024)

![コピー先](images/chapxx-sitopp/s025)
このサンプルコードでは、見やすいよう改行を入れています。

例）他のメーカーの場合、「uint8_t daikin_code[35]={}」は使わず、「irsend.sendDaikin(daikin_code);」でも送信できません。「他のメーカーの場合」を参照ください。



* スケッチエディタの左上にある「→」アイコンをクリックして、M5StickCに書き込みします。
* ファイルの保存場所を聞かれるので、適当に指定します。
* 書き込みにかかる時間、数十秒を待ちます。
* スケッチエディタの下半分にインストールログがどどっと出力され、「Hard resetting via RTS pin...」メッセージが出たらインストール完了です。
* USBケーブルを抜いて、M5StickCをエアコンの50cn以内に持って行きます。赤外線送受信ユニットは抜かずにさしたままです。M5ボタンを押すと、エアコンがつきました。

![M5StickCでエアコンを操作しているところ](images/chapxx-sitopp/s023)

### トラブルシュート

赤外線は可視光線ではないので、出ているかどうかわからないのですが、スマホのフロントカメラで赤外線送受信ユニットの出力部分を見ると、光った場合にわかります。以下はiPhone Xで撮ったの写真です。写真は撮影しなくても、画面で弱く紫っぽい色がかすかに光る所が見えています。

![スマホのフロントカメラだと赤外線が映る](images/chapxx-sitopp/s038)

### 他のメーカーの場合

ありがたい事に、IRremoteESP8266ライブラリの作者のGithubにサンプルコードがあります。

https://github.com/crankyoldgit/IRremoteESP8266

しかしこれだけでは良くわからないかもしれません。2019年にM5StickCが発売されてから、赤外線リモコンを作るのがちょっとしたブームになりました。ブログを書かれた方もいて、そちらを参考にすると国内の主要メーカーのフォーマットはわかると思います。参考にさせていただいた**神ブログ**をいくつかご紹介します。

* M5StickCでスマホから操作できる家電リモコンを作る(NECの例)
https://elchika.com/article/218f5072-28a6-461c-a801-43390305f4cc/

* M5StickC を赤外線リモコンにする（各種テレビメーカーの例）
https://kuratsuki.net/2019/07/



## AdafruitのMQTTブローカの設定

* Adafruit（エイダフルート）https://io.adafruit.com/ にアクセスし、アカウントを作成します。
* 「Actions」 → 「Create a New Dashboard」で、ダッシュボードを作成します。

Name：voiceflowIRDev
Description：開発用

* 「Feeds」 → 「View All」 → 「Actions」 → 「Create a new feed」でFeedsを作成します。

Name：daikin_onoff
Description: Daikin 赤外線リモコン なりすまし用

* 「Feeds」 → 「View All」→ 「daikin_onoff」 → 「Feed Info」
「MQTT by Key」のところにMQTTのTopicが自動生成されていますので、メモ帳にコピーしておきます。

![MQTTのTopics](images/chapxx-sitopp/s027)


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




## IFTTTでMQTTの簡易パブリッシャーを作る

webhooksで発行されたURLにアクセスすると、AdafruitのMQTTブローカーにTopicをパブリッシュするという仕組みを作ります。

* IFTTT（イフト）にログインします。 https://ifttt.com/
* 右上の人型アイコンをクリック → プルダウンメニューが表示されたら、「Create」 をクリック
* 「Create your own」画面で「This」をクリック
* 「Search services」という入力欄に「webhooks」と入力 → 表示された「Webhooks」のパネルをクリック
* 初めての人は、「Connect Webhooks」という画面が表示されるので、Connectをクリックする。 
* 「Receive a web request」のパネルをクリック→ Event Nameの設定画面で、文字を入力する

```
Event Name：M5StickCIRRemoCon
```

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
* 「Make a POST or GET web request to:」の下にあるURLの{event}のところに「M5StickCIRRemoCon」と入力し、URL全体をコピーして、メモ帳などに控えておく。
* 「With an optional JSON body of:」の下にあるJsonをコピーして、メモ帳などに控えておく。

```
URL：https://maker.ifttt.com/trigger/M5StickCIRRemoCon/with/key/(略)
JSON：{ "value1" : "", "value2" : "", "value3" : "" }
```

![webhooksのURL](images/chapxx-sitopp/s028)


## VoiceflowでActions On Googleを作成

### 暖房をつけるフローの作成

* Chromeでvoiceflowにアクセスし、ログインします。https://www.voiceflow.com/
* create Project」クリック → 「Enter your Project name」に、Actions名を入力する。

例）Actions名を「しょういんじ」にした場合、Google Homeに「OK Google しょういんじを呼んで」と話しかけると起動できるようになります。

* Select Regions画面で「Japanese」にチェックを入れ、「English(US)」のチェックを外す→「create Project」をクリック

canvasが開いたら、淡々と作っていきます。

* ヘッダ部分の「Alexa Google」の切り替えスイッチを、Googleの方にする。すると「Upload to Alexa」のボタンが「Upload to Google」に変化する。

![AlexaとGoogle切り替えスイッチ](images/chapxx-sitopp/s030)

* Blocksメニューの「▶︎Advanced」をクリックして開き、「Interaction」ブロックをcanvasにドラッグ。
* Homeブロックの「Start」の右端から線を出して繋ぐ。
* クリックして設定画面を開き「Intents」→「+Add Intent」をクリック
* 「Intent_one」の字の上をクリックして編集できる状態にし、「aircon_on」と上書き入力
* 「Enter user reply」入力欄に「暖房つけて」と入力してエンター
* 「Enter user reply」入力欄に「エアコンつけて」と入力してエンター
* 「Enter user reply」入力欄に「暖房をつけて」と入力してエンター
* この要領で「aircon_off」Intentも作成

```
Intent名 ： aircon_on
user reply : 暖房つけて、エアコンつけて、暖房をつけて

Intent名 ： aircon_off
user reply : 暖房けして、暖房を消して、エアコン消して
```
* 同じInteractionブロックをクリックして設定画面を開き、「Choices」をクリック 
* 「+Add Choice」→「1」の選択肢に「aircon_on」を指定
* 「+Add Choice」→「2」の選択肢に「aircon_off」を指定

脚注：ChoicesはAlexaとGoogleで異なるため、アップロード先をAlexaにする場合はそれ用に追加して作る必要があります。お忘れなきよう。

* 一番左の細いペインの上から3番目のアイコン「Variables」をクリック
* Create Variable(Project)の入力欄に「device」と入力してエンター
* するとそのすぐ下のVariablesのリストの末尾に「{device}」が追加される
* 同様に{onoff}も追加

```
Variablesに追加するパラメタ：
{device}
{onoff}
```

* 一番左の細いペインの一番上のアイコン「Blocks」をクリック
* 「▶︎Logic」→「Set」ブロックをCanvasにドラッグ、Interactionの右側「１」から線を出して繋ぐ
* setブロックをクリックし、設定画面を開いたら、以下のように指定。2個目を追加するときには「Add Variable Set」をクリックすると入力欄が追加される。

```
set {device} to: 「aircon」
set {onoff} to: 「on」
```

* 「▶︎Basic」→「Speak」ブロックをCanvasにドラッグ、Setの右側から線を出して繋ぐ
* Speakブロックをクリックし、設定画面を開いたら、以下のように指定。

```
Speaking as Alexa
暖房をつけます
```
* 「▶︎Advanced」→「Integrations」ブロックをCanvasにドラッグ、Speakの右側から線を出して繋ぐ
* Integrationsブロックをクリックし、設定画面を開く。
* 「Chose an Integration」では「Custom API」をクリックし、以下のように指定。


```
Request URL
POST▼　https://maker.ifttt.com/trigger/M5StickCIRRemoCon/with/key/(略)

※先ほどIFTTTのWebhooksで発行されたURLを使います。(略)の所はユーザーごとに異なるkeyが入っているためセキュリティ上省略してますが、記入するときは省略せずに入れてください。
```

* その下にある、「Headers Body Params」のうち、「Headers」をクリックして以下のように設定。

```
Enter HTTP Header：Content-Type
VALUE application/json
```

* その下にある「Headers Body Params」の「body」→「Form Data」をクリックして以下のように入力

```
value1
VALUE {device}

value2
VALUE {onoff}

value3
VALUE t7d=ClVt （任意の文字列を入力してください。）
```
注：「t7d=ClVt」の部分の8文字は、他の人に知られていない文字列を考えて代入してください。
目をつぶってキーボードを滅多打ちにするか、パスワード自動生成サイトなどを使うと良いです(^o^)

![](images/chapxx-sitopp/s029)

### Voiceflow内でブロックの単体テスト

* 入力欄の右の下の方にある「Test Request」をクリック。
* ポップアップが開いたら「Raw」タブを開く。
* 「Congratulations! You're fired the M5StickCIRRemoCon event"」と表示されればOK。もしエラーなら、POSTのURLが間違っているので見直す。

* IFTTT側の発火履歴も確認してみる。IFTTTのMyAppletsにアクセス https://ifttt.com/my_applets 
* 先ほど作ったレシピ「If Maker Event "M5StickCIRRemoCon", then Send data to onoff feed」が一番上に出てくるのでクリック→「Settings」
* 「View activity」ボタンをクリックすると以下の画面が開く。Voiceflowで「Test Request」した時間と、「Applet ran」の時間があってればOK。
* もし履歴が無かったら、Voiceflow側で指定したURLの中のEvent部分と、IFTTT側で指定したEvent Nameが違うので、見直す。正しくは「M5StickCIRRemoCon」。

![IFTTTのWebhoooksの発火履歴](images/chapxx-sitopp/s031)


* 「▶︎Basic」→「Speak」ブロックをCanvasにドラッグし、Integrationsブロックの右側から線を出して繋ぐ
* Speakブロックをクリックし、設定画面を開く。

```
Speaking as Alexa
送信しました。
```
これで「暖房をつける」というフローが完成しました。
「暖房を消す」のフローは後で作成することにして、テストをしてみます。

### Voiceflow内でフローの通しテスト

* ヘッダの一列下にある「Canvas Test Publish」のうち「Test」をクリック
* 画面右下に「Start Test」ボタンが出たらクリック
* 「USER SAYS」入力欄に「暖房つけて」と記入し、エンター押下。すると応答が返ってきます。

```
暖房をつけます。
送信しました。
```

* 先ほどと同様、IFTTTのWebhooksにリクエストが飛んでいるかどうかを確認します。

* IFTTTのMyAppletsにアクセス https://ifttt.com/my_applets 
* 「If Maker Event "M5StickCIRRemoCon", then Send data to onoff feed」→「Settings」
* 「View activity」画面でVoiceflowで「暖房つけて」と入力した時間と、「Applet ran」の時間があってればOK。


### Googleのデベロッパーアカウントとの連携


* Canvasに戻り、右上の「Upload to Google」ボタンを押下
* 「Please provide Dialogflow Credentials Setup instructions can be found here」の「here」をクリック
* 別タブが開いてガイダンスが表示されるので、英語だけど、頑張って読みながら、この通り進めていく。
* Project Nameは「voiceflow-IRRemocon」などとしておきましょう。

![https://learn.voiceflow.com/en/articles/2705386-uploading-your-project-to-google-assistant](images/chapxx-sitopp/s032)

なお、2020年1月12日現在では、「Login with the same account, go back to the Google Actions Console window and hit the Add your first action again.」の次の部分のGoogle側の画面手順が変わっているので、以下のように進めてください。

* https://console.actions.google.com/ で該当のプロジェクトを選び、「Overview」をクリック
* 「Build your Action」→「Add Action(s)」→「Add Action」→「CREATE Action」のポップアップが開く
* （ここからVoice公式の説明に戻ります。）




* Jsonが発行されたら、voiceflowに戻り、「Drop Json File here or Browse」の所にjsonファイルをドラッグ＆ドロップ→「Upload」をクリック
* 接続できたら以下のメッセージが出る


![IFTTTのWebhoooksの発火履歴](images/chapxx-sitopp/s033)


### Googleにアップロード

アップする前にもう一度ロケールを確認します。

* 「canvas Test Publish」の三つのうち、「Publish」をクリック
* 「Google beta」をクリック→Languagesパネルで、「Japanese(ja）」をクリックし、Next
* 「Canvas」に戻り「Upload to Google」のボタンをクリック
* インジケーターが周り、10数秒ほどでアップロード完了し、「Action Upload Successfull」と表示される
* 「You may test on the Google Actions Simulator. 」の部分をクリックすると、別窓でシミュレーターが開く。
* もし失敗したら、ネットワークの接続ミスか、「Googleのデベロッパーアカウントとの連携」を見直してください。

![IFTTTのWebhoooksの発火履歴](images/chapxx-sitopp/s035)


* シミュレーターはいったんスルーして、「Develop」タブを開き、「Japanese」→「Display name」にアクション名を入力。自分の場合、M-1のぺこぱが面白かったので、以下のようにしました。


```
Display name：しょういんじ
Google Assistant voice：Male 1
```

* 右上の「Save」をクリック。
* 「Don't forget to update sample invocations in the directory information page」というガイダンスが出るのですがいったんスルー。
* 「Modify Languages」をクリック、「English」のチェックを外して、「Japanese」だけにチェックが入ってる状態にして、「Save」をクリック。Deleting Languagesの警告がでますが、OKをクリック。

* 「Overview Develop Test Deploy Analytics」のうち「Test」をクリック、

* 画面左下の入力欄に「しょういんじにつないで」と出ているので、カーソルをあわせてエンター押下。
* 「はい。しょういんじのテストバージョンです」と応答があったら、「暖房つけて」と入力してエンター押下。
* 「暖房をつけます。送信しました。」と応答があり、アクションは終了します。

![しょういんじのテスト](images/chapxx-sitopp/s036)


もしエラーが出たら、以下を試してみてください。

* DialogFlowのコンソールを開く https://dialogflow.cloud.google.com/
* 左上の三本線のメニューアイコンをクリックして、先ほど作ったプロジェクトを選び、歯車をクリックします。
* 「General Language MLSettings〜」とタブが並んでいるので「Languages」をクリック
* 「Select Additional Language」をクリックし、「Japanese - ja」を選択
* 「SAVE」をクリック

### 暖房を消すフローの作成

Chromeで開いたvoiceflowの画面に戻り、残りを編集します。

* 一番左の細いペインの一番上のアイコン「Blocks」をクリック
* 「▶︎Logic」→「Set」ブロックをCanvasにドラッグし、Interactionブロックの右側の「2」から線を繋ぐ
* 上記のsetブロックをクリックし、設定画面を開いたら、以下のように指定。

```
set {device} to: 「aircon」
set {onoff} to: 「off」
```
※2個目を追加するときには「Add Variable Set」をクリックすると入力欄が追加される。

* 「▶︎Basic」→「Speak」ブロックをCanvasにドラッグし、上記のSetの右側から線を繋ぐ
* Speakブロックをクリックし、設定画面を開いたら、以下のように指定。

```
Speaking as Alexa
暖房を消します
```
* 上記のSpeakブロックの右側からIntegrationsブロックに線を繋ぐ。


![全体図](images/chapxx-sitopp/s037)

* 全部できたらGoogleにuploadし、先ほどと同じようにシミュレーターで「しょういんじにつないで」→「暖房を消して」と入力し、応答を確認してみましょう。


<!-- 

## M5StickCリモコンをMQTT対応にする

AdafruitのMQTTライブラリを使います。また、Adafruit のMQTT Library をインストールするとついてくるMQTTのサンプルコード「mqtt_2subs_esp8266」をアレンジして使いました。

* Arduino IDEを開き、「スケッチ」→「ライブラリをインクルード」→「ライブラリを管理」→ 検索をフィルタ欄に「Adafruit_mqtt」と検索し、表示されたものをインストール。
* 「ファイル」→「新規ファイル」でスケッチエディタを開きます。下敷き表示されたコードは削除してください。
* Guthubから私の書いたコードをコピーして、スケッチエディタに貼り付けてください。

```
URL：https://github.com/sitopp/vf_techbookfest8_sampleCode
ファイルパス：M5StickC/IRsend_DAIKIN_MQTT_forM5StickC.ino
```

* Wifiのアカウント、Adafruitのユーザー情報、赤外線のパターンは、ご自分の情報で書き換えてください。
10〜11行目、17〜18行目、79〜85行目、91〜97行目の部分です。

```
10 #define WLAN_SSID       ""  //WiFiのSSID
11 #define WLAN_PASS       ""  //WiFiのパスワード

17 #define AIO_USERNAME    ""  //AdafruitのUsername
18 #define AIO_KEY         ""  //AdafruitのActive Key

79    uint8_t daikin_code[35] = {
80      0x11, 0xDA, 0x27, 0x00, 0xC5, 0x00, 0x00, 0xD7,
81      0000, 0000, 0000, 0000, 0000, 0000, 0000, 0000,
82      0000, 0000, 0000, 0000, 0000, 0000, 0000, 0000,
83      0000, 0000, 0000, 0000, 0000, 0000, 0000, 0000, 0x00, 0x00, 0x39};  
84      //ダミー。自分のリモコンの信号に書き換えること        
85      irsend.sendDaikin(daikin_code); //メーカー毎にクラスが異なる

91    uint8_t daikin_code[35] = {
92      0x11, 0xDA, 0x27, 0x00, 0xC5, 0x00, 0x00, 0xD7,
93      0000, 0000, 0000, 0000, 0000, 0000, 0000, 0000,
94      0000, 0000, 0000, 0000, 0000, 0000, 0000, 0000,
95      0000, 0000, 0000, 0000, 0000, 0000, 0000, 0000, 0x00, 0x00, 0x39};  
96      //ダミー。自分のリモコンの信号に書き換えること        
97      irsend.sendDaikin(daikin_code); //メーカー毎にクラスが異なる
``` -->
<!-- 

* スケッチエディタの左上にある「→」アイコンをクリックして、M5StickCに書き込みします。
* 保存場所を聞かれるので、適当に指定します。
* 書き込みにかかる時間、数十秒を待ちます。
* 「ツール」→「シリアルモニタ」をクリックして、窓を開きます。

IFTTTのWebhooksに付属のTestツールを使って、結合テストしてみましょう。

* ChromeでIFTTTの「My Services」にアクセス https://ifttt.com/my_services 
* 「webhooks」 → 「Documentation」
* 「Make a POST or GET web request to:」の下にあるURLの{event}のところに「M5StickCIRRemoCon」と入力
* 「With an optional JSON body of:」に「{ "value1" : "aircon", "value2" : "on", "value3" : "t7d=ClVt" }」と入力
* 「Test It」をクリック
* シリアルモニタに、以下のメッセージが表示される事を確認。


```
19:26:32.531 -> On-Off button: M5StickCIRRemoCon aircon on t7d=ClVt
19:26:32.568 -> onを通過
```

* OFFの方も確認しましょう。「With an optional JSON body of:」の「"value2" : **"on"**」を「 "value2" : **"off"**」に変更
* 「Test It」をクリック
* シリアルモニタに、以下のメッセージが表示される事を確認。

```
19:26:37.849 -> On-Off button: M5StickCIRRemoCon aircon off t7d=ClVt
19:26:37.886 -> offを通過
```


* M5StickCをUSBケーブルから外し、エアコンの1m以内程度に置いてきてください。（赤外線ユニットは繋いだまま！）
* ChromeのIFTTTのWebhook テストツールから、onやoffの信号を送り、エアコンがついたり消えたりすることを確認してください。



## 全部をつなげて動作確認

まず、Actions On Googleのコンソールから実行してみましょう。
* Chromeで https://console.actions.google.com/ にアクセス
* 「Test」→ 左下の入力欄に「しょういんじにつないで」と表示されているので、クリックしてからエンター押下
* 「わかりました。しょういんじのテストバージョンです。」と応答があったら、「暖房つけて」と記入してエンター押下
* 「暖房をつけます。送信しました。」と男性の声で読み上げたあと、1秒後にエアコンがつく。

![Simulator](images/chapxx-sitopp/s039)


うまくいったら、今度は実機から試してみましょう。
Google homeやGoogle Home Mini、Nest Hubなどをお持ちの人は、開発で使ったのと同じGoogleアカウントでログインしておいてください。


* 「OK Google、しょういんじを呼んで」と呼びかけると、「はい、しょういんじのテストバージョンです」と応答。
* つづけて「暖房をつけて」とお願いすると、「暖房をつけます。送信しました。」と応答し、エアコンがつく。

* 「OK Google、しょういんじを呼んで」と呼びかけると、「はい、しょういんじのテストバージョンです」と応答。
* つづけて「暖房を消して」とお願いすると、「暖房を消します。送信しました。」と応答し、エアコンが停止。

スマホのGoogle Assistantでももちろん利用可能です。iPhoneかAndroidのスマホに、アプリをインストールしておき、アプリを開いた状態で、「しょういんじを呼んで」と呼びかけると、Google Homeの実機と同じようにテストができます。


## まとめ

いかがだったでしょうか？


なおVoiceflowを使うと、Amazon AlexaとGoogle Homeの両方に対応できるのですが、これまで技術書典で「温泉BBA」で本を売っているときにお客さんと話すと、Google Homeを持っているという人が多かったので


 -->
