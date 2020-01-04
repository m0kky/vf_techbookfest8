# M5StickCで赤外線リモコンを作り、AlexaやGoogle Homeから家電を操作する。


## 手に入る知識

- M5StickCで赤外線リモコンを作成
- VoiceflowからMQTTを使う方法



FirebaseにNode.jsをホスティングし、MQTTのパブリッシャを動かしましょう。

node.js、npmのバージョンを確認します。
node --version
npm --version

nodeは8以上、
npmはインストールされてればOKです。自分の環境でnpmは6.9.0でした。

Firebaseのアカウントを作成し、プロジェクトも作成します。
https://firebase.google.com/
「使ってみる」＞「プロジェクトを作成」から画面通りに進めます。
自分の場合、プロジェクトの名前は「MQTT-publisher-demo」としました。

FirebaseのCLIをインストール
npm install -g firebase-tools

ログイン
firebase login

cd
mkdir workspace
cd workspace
mkdir firebase
cd firebase
firebase init

「Which Firebase CLI features do you want to set up〜」というメッセージが出たら、
カーソルの上下で移動して「Function」でスペースキーを入力して選択状態にし、と「Hosting」も同様にします。
選んだらエンター。

「First, let's associate this project diary with a Firebase project.〜」というメッセージが出たら、
カーソルの上下で移動して、「Create a new project」でエンター。

 Please specify a unique project id (warning: cannot be modified afterward) [6-
30 characters]:

というメッセージが出たら、好きな単語を入力してください。
例）voiceflow-mqtt-publisher

What would you like to call your project? (defaults to your project ID) ()
は特に入力せずにエンター。

あたらしいプロジェクトを作成するのに、数十秒かかります。
続けて、node.jsの設定をしていきます。

「What language would you like to use to write Cloud Functions? 」
→ JavaScript
Do you want to use ESLint to catch probable bugs and enforce style?
→y
 Do you want to install dependencies with npm now?
→y

 What do you want to use as your public directory? (public)
→ エンター
Configure as a single-page app (rewrite all urls to /index.html)? 
→N

プロジェクトができたら

cd functions
vi index.js
===

1 const functions = require('firebase-functions');
2   
3 // // Create and Deploy Your First Cloud Functions
4 // // https://firebase.google.com/docs/functions/write-firebase-functions
5 //
6 // exports.helloWorld = functions.https.onRequest((request, response) => {
7 //  response.send("Hello from Firebase!");
8 // });

====
上記の6〜8行目のコメントアウトを外して保存します。
viのコマンドが苦手な人は、VSCodeなどのエディタでファイルを開いてもOKです。
====
1 const functions = require('firebase-functions');
2   
3 // // Create and Deploy Your First Cloud Functions
4 // // https://firebase.google.com/docs/functions/write-firebase-functions
5 //
6  exports.helloWorld = functions.https.onRequest((request, response) => {
7   response.send("Hello from Firebase!");
8  });
====

ファイルを保存したら、ターミナルで以下のコマンドを実行します。
Macのローカル上でのみアクセス可能なホストを立ち上げる命令です。
firebase serve --only functions

数秒待って「functions[helloWorld]: http function initialized (http://localhost:5000/voiceflow-mqtt-publisher/us-central1/helloWorld).」というメッセージが出たら、

Chromeで、以下のURLにアクセスしてみましょう。
http://localhost:5000/プロジェクト名/us-central1/helloWorld

例）http://localhost:5000/voiceflow-mqtt-publisher/us-central1/helloWorld

「Hello from Firebase!」という文字が表示されればOKです。
ターミナルに戻り、Control+Cでプロセスを終了させます。


ではFirebaseにデプロイしてみましょう。


firebase deploy 

1〜2分ほどかかります。

✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/voiceflow-mqtt-publisher/overview
Hosting URL: https://voiceflow-mqtt-publisher.firebaseapp.com
というメッセージが出れば完了です。

ブラウザから「Hosting URL:〜」のURLにアクセスしてみましょう。

Welcome
Firebase Hosting Setup Complete
というメッセージが出れば、OKです。


次に、このindex.jsに、MQTTのトピックスを送るコードを付け足します。

現在位置を確認します。

pwd
「/Users/ユーザー/workspace/firebase/functions」のはず。
違う場所にいたら移動してきましょう。
cd ~/workspace/firebase/functions

「MQTT.js」を使いますので、必要なパッケージをインストールします。
npm install mqtt --save

===
const functions = require('firebase-functions');
var mqtt    = require('mqtt');
var client  = mqtt.connect('mqtt://test.mosquitto.org');

exports.helloWorld = functions.https.onRequest((request, response) => {
 response.send("Hello from Firebase!");
 
 client.subscribe('presence');
 client.publish('presence', 'Hello mqtt');
 
 client.on('message', function (topic, message) {
   // message is Buffer
   console.log(message.toString());
 });
client.end();
});
===

ローカルにデプロイ
firebase serve --only functions

「✔  functions[helloWorld]: http function initialized (http://localhost:5000/voiceflow-mqtt-publisher/us-central1/helloWorld).」
というメッセージが表示されたら、Chromeから上記のURLにアクセス。

例）http://localhost:5000/voiceflow-mqtt-publisher/us-central1/helloWorld

ブラウザに「Hello From Firebase!」と表示され、
ターミナルには、

i  functions: Beginning execution of "helloWorld"
i  functions: Finished "helloWorld" in ~1s
>  Hello mqtt 23
>  Hello mqtt

のように表示されればOKです。
ターミナル上で、Coutrol + cでプロセスを終了します。

次に、index.jsを以下のように変更します。
MQTTのトピックスは、他の人とは違うものをつける必要がありますので、
mynameeeeeeeのところは、「sitopharahetta」のように自分だけの文字列に変更してください。

===
const functions = require('firebase-functions');
var mqtt = require('mqtt');
var client = mqtt.connect('mqtt://test.mosquitto.org');
var command = ''; //初期化

exports.mqtt = functions.https.onRequest((request, response) => {
  response.send("Hello from Firebase!");

  // console.log(JSON.stringify(request)); //デバッグ

  var result = request.url.replace('/?p=', '');
  var command = '0';
  // console.log("result=" + result);

  if (result === 'on') {
    command = '1';
  } else {
    command = '0';
  }

  client.subscribe('mynameeeeeee/voiceflow/mqtt/infrared');
  client.publish('mynameeeeeee/voiceflow/mqtt/infrared', command);

  client.on('message', function (topic, message) {
    // message is Buffer
    console.log(message.toString());
  });
  client.end();
});

===

保存したら、ローカルで実行してテストします。

firebase serve --only functions

✔  functions[mqtt]: http function initialized (http://localhost:5000/voiceflow-mqtt-publisher/us-central1/mqtt).

URLの末尾がmqttに変化していますね。
ではブラウザから以下のURLにアクセスしてください。

http://localhost:5000/プロジェクト名/us-central1/mqtt?p=on

例）http://localhost:5000/voiceflow-mqtt-publisher/us-central1/mqtt?p=on

すると、ターミナルにURL引数がカットされて表示される筈です。

i  functions: Beginning execution of "mqtt"
i  functions: Finished "mqtt" in ~1s
>  1

上記のように「1」、が正解です。
一度ターミナルからcontrol+cで終了させて、再度
firebase serve --only functions
でプロセスを起動し、今度は末尾を「off」にしてリクエストしてみましょう。
http://localhost:5000/プロジェクト名/us-central1/mqtt?p=off

例）http://localhost:5000/voiceflow-mqtt-publisher/us-central1/mqtt?p=off

ターミナル上で、
i  functions: Beginning execution of "mqtt"
i  functions: Finished "mqtt" in ~1s
>  0
とログが出るはずです。

ここまでできたら、Firebaseにデプロイしましょう。
ファンクション名をhelloworldからmqttに変更したので、
「? Would you like to proceed with deletion? Selecting no will continue the rest of the deployments.」というメッセージが出るはず。yと入力して進めます。


デプロイした新しいFunctionにChromeからパラメタ付きでアクセスします。

https://voiceflow-mqtt-publisher.firebaseapp.com/?p=on

