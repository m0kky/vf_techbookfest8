# Googleスプレッドシートと連携してみよう

VoiceflowのGoogleスプレッドシート連携機能を使うと、普段お使いのExcelと同じ使い勝手で使える簡易なデータベースとして利用できますので、スキル開発の幅が一気に広がります。ぜひ活用してワンランク上のスキルを作ってみましょう。

## スプレッドシートのデータをランダムに呼び出す

最初に、VoiceflowのGoogleスプレッドシート連携の基本的な使い方を学びつつ、シートからランダムにデータを取り出すというのをやってみましょう。サンプルとして、Googleスプレッドシートに登録してあるオススメのレシピとその材料をランダムに教えてくれるスキルを作っていきたいと思います。

### スプレッドシートの作成と、スキルの基本部分の作成

最初に、お持ちのGoogleアカウントでGoogleスプレッドシートにログインし、以下のようなスプレッドシートを作成してください。

![](images/chapxx-kun432/s009.png)

- スプレッドシート名は「我が家のレシピデータ」、シート名（下のタブ）は「レシピ一覧」とします。
- 以下のようなデータを入力します。
  - A1に```recipe_name```、B1に```recipe_content```と入力します。1行目が必ず見出しの行となります。日本語での指定はできませんのでご注意ください。
  - 2行目以降は、A列にレシピ名、B列に材料を入力していきます。

次に、Voiceflow側で以下のようなプロジェクトを作成して、ブロックを配置してください。


![](images/chapxx-kun432/s069.png)

- プロジェクト名は「我が家のレシピ」とします。言語は「Japanese(ja-JP)」のみを選択してください。
- プロジェクトが作成されたら、Speakブロックを1つ配置し、HomeブロックのStartと線でつなげます。
- Speakブロックには以下のように設定してください。

//emlist[][]{
我が家のレシピスキルにようこそ。このスキルではおすすめのレシピをランダムに教えるよ。今日のおすすめは、<audio src="soundbank://soundlibrary/ui/gameshow/amzn\_ui\_sfx\_gameshow\_intro\_01"/>
//}

ちなみに、最後の```<audio src=〜```の部分は、「Alexa Skills Kitサウンドライブラリ」を使って効果音を再生するようにしています。

//note[Alexa Skills Kitサウンドライブラリ]{
@<href>{https://developer.amazon.com/ja-JP/docs/alexa/custom-skills/ask-soundlibrary.html}
//}

### Googleスプレッドシートとの連携を行う「Integrationブロック」

Googleスプレッドシートとの連携は「Integrationブロック」を使います。左のBlocksメニューにあるAdvancedから、Integrationブロックをドラッグ・アンド・ドロップでSpeakブロックの右側に配置して、線でつないでください。

![](images/chapxx-kun432/s002.png)

右側に表示されるIntegrationブロックの設定で、「Google Sheets」（Googleスプレッドシートのことを英語ではGoogle Sheetsと呼びます）をクリックします。

![](images/chapxx-kun432/s002-2.png)

まず、シートのデータをどうしたいのか？を選択します。

![](images/chapxx-kun432/s003.png)

以下の4つから選択します。

- Retrieve Data（データの取得： スプレッドシートからデータを読み出す）
- Create Data（データの登録： スプレッドシートにデータを1行追加する）
- Update Data（データの更新： スプレッドシートのデータを1行更新する）
- Delete Data（データの削除： スプレッドシートのデータを削除する）

このスキルでは、レシピ名と材料名のデータをGoogleスプレッドシートから取り出しますので、「Retrieve Data」クリックします。

![](images/chapxx-kun432/s003-2.png)

次に、GoogleスプレッドシートへアクセスするためにGoogleアカウントとの紐付けを行います。「＋Add User」をクリックします。

![](images/chapxx-kun432/s004.png)

はじめてアカウント連携を行う場合は以下のようにGooogleへのログインを促す画面が表示されます。「Login with Google」をクリックします。

![](images/chapxx-kun432/s005.png)

Googleアカウントの選択画面が表示されますので、Googleスプレッドシートを作成したアカウントを選択します。アカウント・パスワードを入力する画面が表示される場合もあります。その場合はお手持ちのGoogleアカウントとパスワードでログインしてください。

![](images/chapxx-kun432/s006.png)

初回のみ、VoiceflowからGoogleスプレッドシートへのアクセス許可設定を行う必要があります。「許可」をクリックします。

![](images/chapxx-kun432/s007.png)

以下のように表示されればGoogleアカウントとの紐付けは完了しています。「Using Sheet」をクリックして次に進みます。

![](images/chapxx-kun432/s008.png)

「Using Sheet」では、Voiceflowからアクセスするスプレッドシートを選択します。「Spreadsheet」でスプレッドシート名、「Sheet」でシート名（下のタブ名）をそれぞれリストから選択します。今回、最初に作成したスプレッドシートの場合だと、「Spreadsheet」に「我が家のレシピデータ」、「Sheet」に「レシピデータ一覧」を選択します。

![](images/chapxx-kun432/s011.png)

スプレッドシートの選択が完了すると、「With Settings」が表示されます。ここで本来は検索条件を指定しますが、ランダムの場合は、左側の「Column」にリストから「Row Number」を選択し、右側の「Value to Match」は何も入力せずに「Next」をクリックします。

![](images/chapxx-kun432/s035.png)

「Mapping Output」のところも、あとで設定しますのでそのまま「Next」をクリックします。

![](images/chapxx-kun432/s036.png)

「Test Integration」では、実際にGoogleスプレッドシートへの接続テストが行えます。「Test Integration」をクリックしてください。

![](images/chapxx-kun432/s037.png)

「Test Integration」の下に、スプレッドシート内に記載されているレシピ名と材料が表示されていれば成功です。何度か「Test Integration」をクリックして、結果がランダムに変わることを確認してください。

![](images/chapxx-kun432/s014.png)

### 変数を使ってスプレッドシートのデータをスキル内で使用する

Googleスプレッドシートとの連携ができましたが、まだスキル内からはそのデータを使うことはできません。スプレッドシートから取得したデータをスキル内で使用するには「変数」を使う必要があります。最初に変数を作成しましょう。

変数の作成は「Variablesメニュー」から行います。画面の一番左、縦に3つ並んでいるアイコンの中から、一番下のアイコンをクリックしてください。

![](images/chapxx-kun432/s016.png)

今まで表示されていた「Blocksメニュー」から表示が切り替わりました。これが「Variablesメニュー」です。「Create Variable」と書いてあるすぐ下の入力フォームに変数名を入力してENTERキーを押すと変数が作成されます。まず```varName```と入力してENTERキーを押してください。

![](images/chapxx-kun432/s038.png)

入力欄のすぐ下に表示されている ```sessions``` 等の最後に```varName```が表示されていれば、変数の作成成功です。同様に、```varContent```という変数も作成してください。

![](images/chapxx-kun432/s039.png)

以下のように2つの変数が作成されていればOKです。一番左の3つのアイコンの、一番上のアイコンをクリックして「Blocksメニュー」に戻りましょう。

![](images/chapxx-kun432/s041.png)

次に、Googleスプレッドシートから取得したデータを変数と紐付けます。これにより他のブロックから変数に入っているデータ（「値」と言います）を呼び出すことができるようになります。Integration Blockをクリックして設定画面を表示し、「Mapping Output」をクリックします。

![](images/chapxx-kun432/s051.png)

変数と取得したデータの紐付けは「Mapping Output」で行います。「+Add Mapping」をクリックします。

![](images/chapxx-kun432/s050.png)

「+Add Mapping」をクリックすると、「Column」と「Variable」をそれぞれ選択できるようになります。「Column」でスプレッドシートから取得したデータのカラム名を、「Variable」でそれを紐付ける変数名を指定します。これでスプレッドシートのデータと変数が紐付けられるというわけです。

![](images/chapxx-kun432/s050.png)

では、まず「レシピ名」から紐付けを行っていきましょう。「Column」をクリックして```recipe_name```を選択します。

![](images/chapxx-kun432/s024.png)

次に「Variable」は```varName```を選択します。

![](images/chapxx-kun432/s055.png)

これで、スプレッドシートの```recipe_name```カラムに入っていたデータが変数```varName```に入るようになりました。同様にして「材料、```recipe_content```カラムと変数```varContent```も紐付けます。「+Add Mapping」をクリックして同じように設定を追加してください。

![](images/chapxx-kun432/s056.png)

2つとも紐付けができてこのようになっていればOKです。「Next」をクリックして「Test Integration」でテストしておいてください。

![](images/chapxx-kun432/s058.png)

//note[IntegrationブロックでGoogleスプレッドシート連携を選択した場合のテストについて]{
IntegrationブロックでGoogleスプレッドシート連携を選択した場合、「Test Integration」で確認できるのはスプレッドシートのデータが取得できたかどうか？だけで、データが変数に入ったかどうかまではわかりません。実際の確認はSpeakブロックなどでその変数を使ってみて確認する必要があります。
//}

では、スプレッドシートから取得したデータをスキルの中から使ってみましょう。Interactionブロックの横にSpeakブロックを配置して、Interactionブロックの「fail」と書いていない方とつなげます。

![](images/chapxx-kun432/s060.png)

Speakブロックの設定は以下のように設定します。

```
{varName} です。材料は {varContent} です。
```

ではAlexa開発者コンソールにアップロードしてテストしてみましょう。何度かスキルを実行して、Googleスプレッドシートのデータが取得できていること、そして、データがランダムに変わることが確認できればOKです。

![](images/chapxx-kun432/s062.png)

### Interactionブロックが失敗した場合に備える

とても便利なGoogleスプレッドシート連携ですが、通信障害や設定ミスなどにより、スプレッドシートにアクセスできなかったり、データが取得できなかったりする可能性があります。きちんとエラー処理を行っておきましょう。

Interactionブロックの横にSpeakブロックを配置して、Interactionブロックの「fail」と書いていない方とつなげます。

![](images/chapxx-kun432/s066.png)

Speakブロックの設定は以下のように設定します。

```
ごめんなさい、エラーが発生しました。しばらく経ってからまたご利用ください。
```

これで、Googleスプレッドシート連携時にエラーが発生した場合はこのSpeakブロックが実行されるようになります。

## 条件を指定してスプレッドシートのデータを取得する。

では次に条件を指定しての検索をやってみましょう。ユーザになんのどのレシピを知りたいか？を聞いて、その発話を受け取ってスプレッドシートを検索してみたいと思います@<br>{}。

ユーザの発話の受け取りが必要になりますので、少しフローを変更します。まず、変数を作りましょう。Variablesメニューに切り替えて、```varUserRecipe```という変数を作成してください。ここにユーザの発話したレシピ名が入ります。

![](images/chapxx-kun432/s070.png)

最初のSpeakブロックの中身を修正します。

![](images/chapxx-kun432/s071.png)

```
我が家のレシピスキルにようこそ。このスキルでは、レシピの名前を言うと材料名を聞くことができるよ。例えば「ハンバーグのレシピが知りたい」と言ってみてね。
```

最初のSpeakブロックとIntegrationブロックの間に、InteractionブロックとSpeakブロックを追加して、以下のようにつなげてください。

![](images/chapxx-kun432/s072.png)

Interactionブロックでインテント/サンプル発話/スロットを作っていきます。Interactionブロックをクリックして、設定のSlotタブで以下のように設定してください。

![](images/chapxx-kun432/s073.png)

- 「+Add Slots」をクリック
- 「slot_one」という名前のスロットが追加されるので、```slot_recipe_name```に変更します。
- 下の「Select Slot Type」から、今回はレシピ名＝食べ物の名前になるので「Food」を選択します。

次にIntentsタブです。ここでインテントとサンプル発話を追加します。

![](images/chapxx-kun432/s074.png)

- 「+Add intent」をクリック
- 「intent_one」という名前のインテントが追加されるので、```intent_ask_recipe```に変更します。
- 下の「Enter user reply」に以下のサンプル発話を追加します。

```
[slot_recipe_name] のレシピが知りたい
[slot_recipe_name] のレシピを教えて
[slot_recipe_name] の材料を知りたい
[slot_recipe_name] の材料を教えて
[slot_recipe_name] のレシピ
[slot_recipe_name] の材料
[slot_recipe_name]
```

最後にChoicesタブです。ここでインテントと会話のフローを紐付けます。

![](images/chapxx-kun432/s075.png)

- 「+Add Choice」をクリック
- 「Select Intent」に「intent_ask_recipe」を選択します。
- 「+Add Variable Map」をクリック
- 左側の「Slot」は```[slot_recipe_name]```、右側の「Select Variable」は```{varUserRecipe}```をそれぞれ選択します。

上のSpeakブロックは、Interactionブロックで設定したインテントに当てはまらない発話を受け取った場合に、もう一度聞き直すために使います。以下のように入力します。

```
ごめんなさい、うまく聞き取れませんでした。例えば「ハンバーグのレシピが知りたい」という風に言ってみてください。
```

これで発話を受け取る準備ができました。では、その発話をもとにスプレッドシートを検索するようにしてみましょう。Integrationブロックをクリックして、「With Settings」をクリックします。

ランダムの場合は、左側は「Row Number」を選択して、右側の「Value to Match」は空にしていました。これを以下のように、左側は「recipe\_name」に、右側は```{varUserRecipe}```を入力します。これで「recipe\_name」カラムに変数```varUserRecipe```で発話したものを指定して検索ができるということです。逆にランダムの場合は「Row Number」を指定して「Next」をクリックします。

「Mapping Output」はそのまま「Next」をクリックします。

「Test Integration」をクリックします。

ランダムの場合とは変わった画面が出てきました。検索条件を変数で指定するとこのように変数の値を変えながらテストができます。試しに「カレーライス」と入力して「Run」をクリックしてみてください。

ちゃんとカレーライスのデータが取得できていますね。他にも用意したレシピ名で検索して、条件に合致したデータが取得できることを確認してください。

ではAlexa開発者コンソール側でもテストしてみましょう。

うまく動いてますね。今度は、レシピデータに登録していないレシピ名で試してみてください。

```undefined``` は「何も定義されていない」ということを意味しています。レシピデータにないレシピ名を検索しようとしたので当然なのですが、Alexaがこういう回答を返すのはちょっと良くないですね。少し修正しましょう。

Integrationブロックと、Integrationブロックが成功したときのSpeakブロック（failじゃない方）の線をいったん削除して、IntegrationブロックにIfブロックをつなげます。

Ifブロックは条件を指定してその結果によって処理の流れを分岐させるブロックです。ここでは、Integrationブロックでレシピ名からデータが検索できた場合と、できなかった場合の分岐を行うようにします。

ストレートに考えると、スプレッドシートから取得したデータが入っている変数```varName```か変数```varContent```が```undefined```かどうか、を比較すればよいのですが、```undefined```はプログラム的にいうと少し特殊で、以下のように設定してもうまく動きません。

そこで少しひねります。ユーザが発話したレシピ名で検索ができたということは、ユーザが発話したレシピ名が入っている変数```varName```と、スプレッドシートから取得したレシピ名が入っている変数```varName```はイコールになっているはずですよね？つまりこれを比較すれば、検索結果が取得できたかどうかがわかります。以下のように設定してください。


これで、検索結果が取得できた場合は、「1」のフローへ、できなかった場合は「else」のフローに進むという分岐ができました。

//note[undefinedの判定について]{
もちろんストレートにundefindを判定することもできます。VoiceflowのIfブロックにはAdvanced Expressionという記述があり、これを使うとプログラム的な書き方で判定することが可能です。プログラムに慣れた人はこちらのほうがわかりやすいかもしれません。よろしければご覧ください。

Advanced expression (IF and SET blocks) - Voiceflow Docs（英語）@<br>{}
@<href>{https://docs.voiceflow.com/voiceflow-documentation/logic-in-voiceflow/advanced-expression-if-and-set-blocks}

※一番最後にある「For more details you can look here. 〜」のリンクもご覧ください。
」
//}

では、それぞれの結果をSpeakブロックでAlexaに話させましょう。もともとあったSpeakブロックはIfブロックの成功の方につないでください。

## まとめ

いかがでしょうか？Googleスプレッドシートを使ってデータを読み出すと、一気にデータベースな雰囲気が出てきますね。今回は紙面の都合上、データの参照のみ紹介しましたが、もちろんスプレッドシートへ登録・更新・削除も可能です。ぜひご活用ください。

## Googleスプレッドシートを使う場合の注意

お手軽で便利なGoogleスプレッドシート連携ですが、弱点もあります。

- 個人的な印象ですが、Googleスプレッドシートへのアクセスは、一般的なAPI等へのアクセスに比べると少しレスポンスが遅いと感じます。スキルの中でスプレッドシートへのアクセスを何度も行うと、利用者のスキル利用時のテンポやリズム感を損ねる可能性があることにご注意ください。
- また、Googleスプレッドシートへの高頻度のアクセスは、Googleからアクセス制限される可能性があります。一般的なスキル利用程度であれば問題ないと思いますが、スキルが人気になった場合などはこの制限の対象になる可能性があることにご注意ください。
- Googleスプレッドシートに大量のデータが存在する（行数や列数が多い、セル内の文字数が多い、等）場合、レスポンスが遅くなったり、データが取得できなくなったりする場合があります。行・列・セル内データ等の組み合わせにもよるので一概には言えませんが、多くても1000行未満に抑えることをオススメします。
- Googleスプレッドシートで検索する場合、検索対象の列は1つしか指定できません。一般的なデータベースで行うような複雑な検索条件は実行できませんのでご注意ください。

上記のような制限に合致したり、Googleスプレッドシートで機能的に物足りなくなったら、AirtableやFirebaseなどの本格的なデータベースを利用することをオススメします。Googleスプレッドシートよりも少し難易度が上がりますが、是非トライしてみてください。

- Airtable (@<href>{https://airtable.com/})
- Firebase (@<href>{https://firebase.google.com/})

## 最後に

私のブログでいくつかGoogleスプレッドシート関連のチュートリアル的な記事を書いていますのでご紹介します。よろしければご覧ください。

「Voiceflow Tips #7 Googleスプレッドシート連携で作る豆知識スキル」@<br>{}
(@<href>{https://kun432.hatenablog.com/entry/voiceflow\_tips\_7\_fact\_skill\_integrated\_with\_google\_sheets})

初歩のAlexaスキル開発のサンプルとしてもよく取り上げられている「豆知識」スキルをGoogleスプレッドシートと連携させて作ります。今回のランダムなGoogleスプレッドシート側に豆知識の「ネタ」をたくさん登録しておいて、ランダムに呼び出すというものです。

- 「Voiceflow Tips #12 Googleスプレッドシート連携で作るゼロカロリースキル 〜スプレッドシートの検索〜」@<br>{}
(@<href>{https://kun432.hatenablog.com/entry/voiceflow\_tips\_12\_retrieve\_from\_google\_spreadsheet})
- 「Voiceflow Tips #14 Googleスプレッドシート連携で作るゼロカロリースキル 〜スプレッドシートへの登録〜」@<br>{}
(@<href>{https://kun432.hatenablog.com/entry/voiceflow\_tips\_14\_insert_data\_into\_google\_sheets})
- 「Voiceflow Tips #18 Googleスプレッドシート連携で作るゼロカロリースキル 〜スプレッドシートの更新〜」@<br>{}
(@<href>{https://kun432.hatenablog.com/entry/voiceflow\_tips\_18\_update\_data\_with\_google\_sheets})
- 「Voiceflow Tips #19 Googleスプレッドシート連携で作るゼロカロリースキル 〜スプレッドシートの削除〜」@<br>{}
(@<href>{https://kun432.hatenablog.com/entry/voiceflow\_tips\_19\_delete\_data\_with\_google\_sheets})

2019年のAlexaスキルハッカソン大阪で話題になっていた、がおまるさん（@gaomar）の「ゼロカロリースキル」をGoogleスプレッドシート連携だけで作るというものです。データベースの基本となる、一連のCRUD操作（Create:登録、 Retrieve:参照、Update:更新、Delete:削除）を4回に分けて紹介しています。

- 「Voiceflow TIPS #29 Airtableと組み合わせて、もっとデータベースらしく」@<br>{}
(@<href>{https://kun432.hatenablog.com/entry/voiceflow\_tips\_29\_integration\_with\_airtable})

Voiceflowでは物足りない場合、

- 「Voiceflow TIPS #35 Firebase RealtimeDatabaseでデータを管理する」@<br>{}
(@<href>{https://kun432.hatenablog.com/entry/voiceflow\_tips\_35\_integration\_with\_firebase\_realtime\_database})

