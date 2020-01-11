# M5StickCで赤外線リモコンを作り、AlexaやGoogle Homeから家電を操作する。

Nature Remo Miniなどのスマートハブは便利ですが、買うと結構高いので、家にあったM5Stackを使って自作してみます。M5Stack用の赤外線送受信ユニット（308円）だけは買い足しました。
IoTに使えるいろんなテクを寄せ集めていますので、何かのヒントになると幸いです。

### 本章でやること

* M5Stackで赤外線リモコン作成
* AdafruitのMQTTブローカの設定
* IFTTTでMQTTの簡易パブリッシャーを作る
* VoiceflowでActions On Googleを作成
* 全部をつなげて動作確認
* * Google HomeからActions On Googleを呼び出し、MQTTでM5Stackへメッセージ送信し、M5STackは赤外線で家電を操作


![アーキテクチャ](images/chapxx-sitopp/s000.png)

### 使用した機材やアカウント

* 機材：
<!-- * * M5StickC ¥1980
* * M5StickCに付属のUSB Type-Cケーブル（注1） -->
* * M5STACK-BASIC ¥3,575
* * M5用、赤外線送受信ユニット ¥308
* * MacBook Air（OS: OS 10.13.6 High Sierra）
* * VSCode
* * Arduino IDE 1.8.9
* * Google Home mini
* * Android/iPhone の「Googleアシスタント」アプリケーション

注1　MacとM5Stackをつなぐ時、M5Stackに付属のUSB Type-Cケーブルを使わないと認識しないことが多いので、なくさないよう大切に保管しておきましょう。

## 手順

## M5StickCで赤外線リモコン作成

<!-- あらかじめ、Arduino IDEでM5StickCを使えるようにしておきます。 -->
あらかじめ、Arduino IDEでM5Stackを使えるようにしておきます。

参考：https://〜


### 赤外線の命令を拾う

<!-- M5StickCにM5Stack赤外線送受信ユニットをさします。Groveケーブルが若干きついので、「やっぱM5Stackじゃないとダメかな」と言う考えが一瞬頭をよぎりますが、ちゃんと入ります。 -->

<!-- Arduino IDEを起動し、M5StickCをUSB Type-Cケーブルで接続します。 -->
Arduino IDEを起動し、M5StackをMacにUSB Type-Cケーブルで接続します。

Arduino IDEの「ツール」→「ライブラリを管理」→「IRremoteESP8266」と入力し、表示されたライブラリをインストールします。

「ファイル」→「スケッチ例」→「IRremoteESP8266」→「IRrecvDumpV2」を開きます。

「ファイル」→「新規ファイル」でスケッチエディタを開き、上で開いた「IRrecvDumpV2」を全文コピーして貼り付け、以下の一行だけ書き換えます。

<!-- ```
const uint16_t kRecvPin = 14;
↓
const uint16_t kRecvPin = 33;
``` -->

```
const uint16_t kRecvPin = 14;
↓
const uint16_t kRecvPin = 22;
```

ツール＞ボード＞「M5Stack-Core-ESP32」を選択しておきます。

ツール＞シリアルポート＞「devほにゃららUSBほにゃらら」を選択します。

「→」をクリックして、M5Stackに書き込みします。

```
Leaving...
Hard resetting via RTS pin...
```
というメッセージが出てプロンプトが止まったら、M5Stackの画面には何も出ませんが、インストールは完了しています。

ツール＞シリアルモニタ でシリアル出力メッセージが閲覧できる窓を開きます。

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


## Shiftrの登録

サインアップあるいはログインします。
https://shiftr.io/

「New Namespace」＞

Name : 好きな名前を。例）project-x
Description：説明を。例）sitopp dev
private：チェックを入れる

Create Namespaceをクリックし、「You haven't created any "full-access" tokens yet
In order to publish messages to this namespace, you have to create "full-access" tokens on the Namespace Settings page.」と表示されたら、「Namespace Settings page」の部分をクリックして設定ページへ。

「Add Token」をクリックすると、開いたページで、すでにKeyとsecret(password)が発行されているので、メモ帳などにコピぺします。Permissionは「full-access」のままにしておきます。
「Description」にはこの後使うユニークなトークンを入力します。
例）
/sitopp/m5/remocon

Create Tokenを押すと、生成されます。

トークン名の下に書かれている、mqtt://〜で始まるURLと、
Graphの下に書かれているmqtt://のURLをメモ帳などにコピペしておきます。

Webhooks(Beta)をクリックし、Add Webhookをクリックします。




## FirebaseにNode.jsをホスティング


Firebase
https://firebase.google.com/
アカウントを持っていなければ作成しておきます。

公式のリファレンス 
https://firebase.google.com/docs/cli?hl=ja を参照しながら、
プロジェクト作成をしていきます。
以下はコマンドの抜粋です。


* Macローカルのバージョン確認

```
node --version
→8以上であること
npm --version
→入っていればOK、自分の環境で6.9.0でした。動かなければ最新版にあげてください。

npm install -g firebase-tools
cd ~
mkdir workspace
cd workspace
mkdir firebase
cd firebase
firebase login
firebase init

Which Firebase CLI features do you want to set up〜
→ Function と Hostingを選択してエンター。

First, let's associate this project diary with a Firebase project.〜
→ Create a new project」を選択してエンター。

Please specify a unique project id (warning: cannot be modified 〜
→プロジェクトIDを決めて入力。
例）voiceflow-mqtt-publisher

What would you like to call your project? (defaults to your project ID) 
→特に入力せずにエンター。

What language would you like to use to write Cloud Functions? 
→ JavaScript

Do you want to use ESLint to catch probable bugs and enforce style?
→y

Do you want to install dependencies with npm now?
→y

What do you want to use as your public directory? (public)
→ エンター

Configure as a single-page app (rewrite all urls to /index.html)? 
→N
```

プロジェクトが作成できたら、npmパッケージをインストールします。

```
cd ~/workspace/firebase/functions
npm install mqtt --save
```

この「functions」ディレクトリ以下にファイル一式が生成されます。
VSCodeを起動して、index.jsファイルを開き、中身を編集しましょう。「mynameeeeeee/voiceflow/mqtt/infrared」の部分が自分専用となるよう、「mynameeeeeee」の部分を自分の名前などに変更してください。
もし他人が宣言した名前とかぶっていた場合、エラーは出ませんが、同じTopicを使ってる人のメッセージを上書きしてしまい、やべぇです（^o^;）必ずユニークになるようにしましょう。

```index.js
const functions = require('firebase-functions');
var mqtt = require('mqtt');
var client = mqtt.connect('mqtt://mqtt.eclipse.org');
var command = ''; //初期化

exports.mqtt = functions.https.onRequest((request, response) => {
  response.send("Hello from Firebase!");

  var result = request.url.replace('/?p=', '');
  var command = '0';
  console.log("result=" + result);

  if (result === 'on') {
    command = '1';
  } else {
    command = '0';
  }

  client.on('connect', () => console.log('publisher.connected.'));
  client.publish('mynameeeeeee/voiceflow/mqtt/infrared', command);
  console.log('publisher.publish:topic=mynameeeeeee/voiceflow/mqtt/infrared,command=', command);

});
```

ファイルを保存したら、ターミナルで以下のコマンドを実行して、Macのローカル上にホストを立ち上げます。

```
firebase serve --only functions
```

以下のようなメッセージが出ます。「voiceflow-mqtt-publisher」の部分は先ほど自分で命名したプロジェクト名になっているはずです。

```
functions[mqtt]: http function initialized (http://localhost:5000/voiceflow-mqtt-publisher/us-central1/mqtt).
```

URLをコピーし、末尾に```?p=on```をつけて、Chromeからアクセスしてみましょう。

```
例）http://localhost:5000/voiceflow-mqtt-publisher/us-central1/mqtt/?p=on
```

![ローカルで実行したところ](images/chapxx-sitopp/s010.png)

正常に動けば、ブラウザに「Hello From Firebase」と表示されます。
ターミナルには以下のログが表示されるはずです。

```
i  functions: Beginning execution of "mqtt"
>  result=on
>  publisher.publish:topic= mynameeeeeee/voiceflow/mqtt/infrared ,command= 1
i  functions: Finished "mqtt" in ~1s
>  publisher.connected.
```

ターミナル上で「Coutrol + c」を入力し、Firebaseのプロセスを終了します。
ではFirebaseのサーバーにデプロイしてみましょう。

```
firebase deploy 
```

「Deploy complete」 というメッセージが出れば完了です。初回は1〜2分、2回目以降でも数十秒かかります。
またURLを教えてくれます。「voiceflow-mqtt-publisher」の部分は先ほど自分で命名したプロジェクト名になります。

```
✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/voiceflow-mqtt-publisher/overview
Hosting URL: https://voiceflow-mqtt-publisher.firebaseapp.com
```

ではChromeから、いま生成したばかりのFunctionにアクセスします。

```
https://（自分のプロジェクト名）.firebaseapp.com/?p=on

例）https://voiceflow-mqtt-publisher.firebaseapp.com/?p=on
```

## IFTTTでMQTTをWebhookする

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


