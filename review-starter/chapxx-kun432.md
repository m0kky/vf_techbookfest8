# Googleスプレッドシートと連携してみよう

VoiceflowのGoogleスプレッドシート連携機能を使うと、普段お使いのExcelと同じ使い勝手で使える簡易なデータベースとして利用できますので、スキル開発の幅が一気に広がります。ぜひ活用してワンランク上のスキルを作ってみましょう。

## スプレッドシートのデータをランダムに呼び出す

最初に、VoiceflowのGoogleスプレッドシート連携の基本的な使い方を学びつつ、シートからランダムにデータを取り出すというのをやってみましょう。サンプルとして、Googleスプレッドシートに登録してあるお勧めのレシピとその材料をランダムに教えてくれるスキルを作っていきましょう。

### スプレッドシートの作成と、スキルの基本部分の作成

最初に、お持ちのGoogleアカウントでGoogleスプレッドシートにログインし、以下のようなスプレッドシートを作成してください。

![](images/chapxx-kun432/s009.png)

- スプレッドシート名は「我が家のレシピデータ」、シート名（下のタブ）は「レシピ一覧」とします。
- A1に```recipe_name```、B1に```recipe_content```と入力します。1行目が必ず見出しの行となります。日本語での指定はできませんのでご注意ください。
- 2行目以降は、A列にレシピ名、B列に材料を入力していきます。

次に、Voiceflow側で以下のようなプロジェクトを作成して、ブロックを配置してください。

![](images/chapxx-kun432/s069.png)

- プロジェクト名は「我が家のレシピ」とします。言語は「Japanese（ja-JP）」のみを選択してください。
- プロジェクトが作成されたら、Speakブロックを1つ配置し、HomeブロックのStartと線でつなげます。
- Speakブロックには以下のように設定してください。

//emlist[][]{
我が家のレシピスキルにようこそ。このスキルではおすすめのレシピをランダムに教えるよ。今日のおすすめは、<audio src="soundbank://soundlibrary/ui/gameshow/amzn\_ui\_sfx\_gameshow\_intro\_01"/>
//}

ちなみに、最後の```<audio src=〜```の部分は、「Alexa Skills Kitサウンドライブラリ」を使って効果音を再生するようにしています。

//note[Alexa Skills Kitサウンドライブラリ]{
@<href>{https://developer.amazon.com/ja-JP/docs/alexa/custom-skills/ask-soundlibrary.html}
//}

//embed[latex]{
\clearpage
//}

### Googleスプレッドシートとの連携を行う「Integrationブロック」

Googleスプレッドシートとの連携は「Integrationブロック」を使います。左のBlocksメニューにあるAdvancedから、Integrationブロックをドラッグ&ドロップでSpeakブロックの右側に配置して、線でつないでください。

![](images/chapxx-kun432/s002.png)

右側に表示されるIntegrationブロックの設定で、「Google Sheets」（Googleスプレッドシートのことを英語ではGoogle Sheetsと呼びます）をクリックします。

![](images/chapxx-kun432/s002-2.png)

//embed[latex]{
\clearpage
//}

まず、スプレッドシートのデータをどうしたいのか、を選択します。Retrieve Data（スプレッドシートからデータを読み出す）/Create Data（スプレッドシートにデータを1行追加する）/Update Data（スプレッドシートのデータを1行更新する）/Delete Data（スプレッドシートのデータを削除する）の4つから選択ができます。今回は、レシピ名と材料名のデータをGoogleスプレッドシートから読み出したいので、「Retrieve Data」をクリックします。

![](images/chapxx-kun432/s003-2.png)

次に、GoogleスプレッドシートへアクセスするためにGoogleアカウントとの紐付けを行います。「＋Add User」をクリックします。

![](images/chapxx-kun432/s004.png)

//embed[latex]{
\clearpage
//}

初めてアカウント連携を行う場合は以下のようにGooogleへのログインを促す画面が表示されます。「Login with Google」をクリックします。

![](images/chapxx-kun432/s005.png)

Googleアカウントの選択画面が表示されますので、Googleスプレッドシートを作成したアカウントを選択します。アカウント・パスワードを入力する画面が表示される場合もあります。その場合はお手持ちのGoogleアカウントとパスワードでログインしてください。そしてVoiceflowからGoogleスプレッドシートへのアクセスを「許可」してください。

![](images/chapxx-kun432/s006-3.png)

//embed[latex]{
\clearpage
//}

以下のように表示されればGoogleアカウントとの紐付けは完了しています。「Using Sheet」をクリックして次に進みます。

![](images/chapxx-kun432/s008.png)

「Using Sheet」では、Voiceflowからアクセスするスプレッドシートを選択します。「Spreadsheet」でスプレッドシート名、「Sheet」でシート名（下のタブ名）をそれぞれリストから選択します。今回、最初に作成したスプレッドシートの場合だと、「Spreadsheet」に「我が家のレシピデータ」、「Sheet」に「レシピデータ一覧」を選択します。

![](images/chapxx-kun432/s011.png)

//embed[latex]{
\clearpage
//}

スプレッドシートの選択が完了すると、「With Settings」が表示されます。ここで本来は検索条件を指定しますが、ランダムの場合は、左側の「Column」にリストから「Row Number」を選択し、右側の「Value to Match」は何も入力せずに「Next」をクリックします。

![](images/chapxx-kun432/s035.png)

「Mapping Output」のところも、あとで設定しますのでそのまま「Next」をクリックします。

![](images/chapxx-kun432/s036.png)

//embed[latex]{
\clearpage
//}

「Test Integration」では、実際にGoogleスプレッドシートへの接続テストが行えます。「Test Integration」をクリックしてください。

![](images/chapxx-kun432/s037.png)

「Test Integration」の下に、スプレッドシート内に記載されているレシピ名と材料が表示されていれば成功です。何度か「Test Integration」をクリックして、結果がランダムに変わることを確認してください。

![](images/chapxx-kun432/s014.png)

### 変数を使ってスプレッドシートのデータをスキル内で使用する

Googleスプレッドシートとの連携ができましたが、まだスキル内からはそのデータを使うことはできません。スプレッドシートから取得したデータをスキル内で使用するには「変数」を使う必要があります。最初に変数を作成しましょう。

変数の作成は「Variablesメニュー」から行います。画面の一番左、縦に3つ並んでいるアイコンの中から、一番下のアイコンをクリックするとメニューが切り替わります。「Create Variable」と書いてあるすぐ下の入力フォームに変数名を入力してENTERキーを押すと変数が作成されます。まず```varName```と入力してENTERキーを押してください。

![](images/chapxx-kun432/s016-2.png)

入力欄のすぐ下に表示されている ```sessions``` 等の最後に```varName```が表示されていれば、変数の作成成功です。同様に、```varContent```という変数も作成してください。

![](images/chapxx-kun432/s039.png)

//embed[latex]{
\clearpage
//}

以下のように2つの変数が作成されていればOKです。一番左の3つのアイコンの、一番上のアイコンをクリックして「Blocksメニュー」に戻りましょう。

![](images/chapxx-kun432/s110.png)

次に、Googleスプレッドシートから取得したデータを変数と紐付けます。これによって、変数に入っているデータ（「値」と言います）を他のブロック内で呼び出すことができるようになります。Integration Blockをクリックして設定画面を表示し、「Mapping Output」をクリックします。

![](images/chapxx-kun432/s051.png)

//embed[latex]{
\clearpage
//}

変数と取得したデータの紐付けは「Mapping Output」で行います。「+Add Mapping」をクリックします。

![](images/chapxx-kun432/s050.png)

「+Add Mapping」をクリックすると、「Column」と「Variable」をそれぞれ選択できるようになります。「Column」でスプレッドシートから取得したデータのカラム名を、「Variable」でそれを紐付ける変数名を指定します。これでスプレッドシートのデータと変数が紐付けられるというわけです。

![](images/chapxx-kun432/s053.png)

//embed[latex]{
\clearpage
//}

では紐付けを行っていきましょう。「Column」には```recipe_name```、「Variable」には```varName```を選択します。

![](images/chapxx-kun432/s024-2.png)

これで、スプレッドシートの```recipe_name```カラムに入っていたデータが変数```varName```に入るようになりました。同様にして「材料、```recipe_content```カラムと変数```varContent```も紐付けます。「+Add Mapping」をクリックして同じように設定を追加してください。

2つとも紐付けができてこのようになっていればOKです。「Next」をクリックして、キャンバスに戻りましょう。

![](images/chapxx-kun432/s058.png)

では、スプレッドシートから取得したデータをスキルの中から使ってみましょう。Interactionブロックの横にSpeakブロックを配置して、Interactionブロックの「fail」と書いていない方とつなげます。

![](images/chapxx-kun432/s060.png)

Speakブロックの設定は以下のように設定します。

```
{varName} です。材料は {varContent} です。
```

ではAlexa開発者コンソールにアップロードしてテストしてみましょう。何度かスキルを実行して、Googleスプレッドシートのデータが取得できていること、とデータがランダムに変わることが確認できればOKです。

![](images/chapxx-kun432/s062.png)

### Interactionブロックが失敗した場合に備える

とても便利なGoogleスプレッドシート連携ですが、通信障害や設定ミスなどにより、スプレッドシートにアクセスできなかったりデータが取得できなかったりする可能性があります。きちんとエラー処理を行っておきましょう。

Interactionブロックの横にSpeakブロックを配置して、Interactionブロックの「fail」と書いていない方とつなげます。

![](images/chapxx-kun432/s066.png)

Speakブロックの設定は以下のように設定します。

```
ごめんなさい、エラーが発生しました。しばらく経ってからまたご利用ください。
```

これで、Googleスプレッドシート連携時にエラーが発生した場合はこのSpeakブロックが実行されます。

## 条件を指定してスプレッドシートのデータを取得する。

では次に条件を指定しての検索をやってみましょう。ユーザーにどのレシピを知りたいかを聞いて、その発話を受け取ってスプレッドシートを検索してみましょう。@<br>{}

### 検索条件となるユーザーの発話を受け取る

ユーザーの発話の受け取りが必要になりますので、少しフローを変更します。まず、変数を作りましょう。Variablesメニューに切り替えて、```varUserRecipe```という変数を作成してください。ここにユーザーの発話したレシピ名が入ります。

![](images/chapxx-kun432/s070.png)

最初のSpeakブロックの中身を修正します。

![](images/chapxx-kun432/s071.png)

```
我が家のレシピスキルにようこそ。このスキルでは、レシピの名前を言うと材料名を聞くことができるよ。例えば「ハンバーグのレシピが知りたい」と言ってみてね。
```

//embed[latex]{
\clearpage
//}

最初のSpeakブロックとIntegrationブロックの間に、InteractionブロックとSpeakブロックを追加して、以下のようにつなげてください。

![](images/chapxx-kun432/s072.png)

Interactionブロックでインテント/サンプル発話/スロットを作っていきます。Interactionブロックをクリックして、設定のSlotタブで以下のように設定してください。

![](images/chapxx-kun432/s073.png)

- 「+Add Slots」をクリック
- 「slot\_one」という名前のスロットが追加されるので、```slot_recipe_name```に変更します。
- 下の「Select Slot Type」から、今回はレシピ名＝食べ物の名前になるので「Food」を選択します。

次にIntentsタブです。ここでインテントとサンプル発話を追加します。

![](images/chapxx-kun432/s074.png)

- 「+Add intent」をクリック
- 「intent\_one」という名前のインテントが追加されるので、```intent_ask_recipe```に変更します。
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

//embed[latex]{
\clearpage
//}

最後にChoicesタブです。ここでインテントと会話のフローを紐付けます。

![](images/chapxx-kun432/s075.png)

- 「+Add Choice」をクリック
- 「Select Intent」に```intent_ask_recipe```を選択します。
- 「+Add Variable Map」をクリック
- 左側の「Slot」は```[slot_recipe_name]```、右側の「Select Variable」は```{varUserRecipe}```をそれぞれ選択します。

上のSpeakブロックは、Interactionブロックで設定したインテントに当てはまらない発話を受け取った場合に、もう一度聞き直すために使います。

![](images/chapxx-kun432/s081.png)

以下のように入力します。

```
ごめんなさい、うまく聞き取れませんでした。例えば「ハンバーグのレシピが知りたい」という風に言ってみてください。
```

### 条件を指定してスプレッドシートのデータを取得する

検索条件となるユーザーの発話を受け取る準備ができました。では、その発話をもとにスプレッドシートを検索するようにしてみましょう。Integrationブロックをクリックして、「With Settings」をクリックします。

![](images/chapxx-kun432/s080.png)

//embed[latex]{
\clearpage
//}

ランダムの場合は、左側は「Row Number」を選択、右側の「Value to Match」は空にしていました。これを以下のように、左側は「recipe\_name」に、右側は```{varUserRecipe}```を入力します。これで「recipe\_name」カラムに変数```varUserRecipe```で発話したものを指定して検索ができるということです。「Next」をクリックします。

![](images/chapxx-kun432/s082.png)

「Mapping Output」はそのまま「Next」をクリックして、「Test Integration」に進み、「Test Integration」をクリックします。

![](images/chapxx-kun432/s083.png)

ランダムの場合とは変わった画面が出てきました。```varUserRecipe```に「カレーライス」と入力して「Run」をクリックしてみてください。

![](images/chapxx-kun432/s085.png)

ちゃんとカレーライスのデータが取得できていますね。このように、「With Settings」で検索条件に変数を使うと、変数の値を自分で指定してテストができます。他のレシピ名で検索して、条件に合致したデータが取得できることを確認してください。

![](images/chapxx-kun432/s086.png)

//embed[latex]{
\clearpage
//}

Alexa開発者コンソール側でも正しく動いてますね。

![](images/chapxx-kun432/s087.png)

### 検索結果がない場合の処理

さきほどのテストの続きで、今度はレシピデータに登録していないレシピ名で試してみてください。

![](images/chapxx-kun432/s089.png)

```undefined``` は「何も定義されていない」ということを意味しています。レシピデータにないレシピ名を検索しようとしたので当然なのですが、Alexaがこういう回答を返すのはちょっと良くないですね。少し修正しましょう。

Integrationブロックと、Integrationブロックが成功したときのSpeakブロック（failじゃない方）の線をいったん削除して、IntegrationブロックにIfブロックをつなげます。Speakブロックは少し脇によけておきましょう。

![](images/chapxx-kun432/s090.png)

Ifブロックは条件を指定してその結果によって処理の流れを分岐させるブロックです。ここでは、Integrationブロックでレシピ名からデータが検索できた場合と、できなかった場合の分岐を行うようにします。

![](images/chapxx-kun432/s091.png)

//embed[latex]{
\clearpage
//}

では条件の設定です。単純に考えると、スプレッドシートから取得したデータが入っている変数```varName```か変数```varContent```が```undefined```になっているので、イコールを使って比較すれば良いと思いますよね。ところが、この```undefined```はプログラム的には少し特殊で、以下のように設定してもうまく動きません。

![](images/chapxx-kun432/s092.png)

そこで少しひねって、```undefined```かどうかを判定せずに、きちんと検索結果ができたかどうかを判定するようにします。まず、上側の「Select Variable」は```varUserRecipe```を選択します。

![](images/chapxx-kun432/s098.png)

次に、下側の「Value」ですが、初期状態だと値を直接入力するだけしかできず変数は選択できません。そこで、一番右端の```</>```アイコンをクリックします。するとメニューが表示されるので「Variable」をクリックします。

![](images/chapxx-kun432/s094.png)

すると、下側も「Select Variable」に変わるので、```varName```を選択します。

![](images/chapxx-kun432/s096.png)

//embed[latex]{
\clearpage
//}

つまり「ユーザの発話したレシピ名（```varUserRecipe```）＝スプレッドシートから取得したレシピ名（```varName```）ならば検索結果が取得できた」というチェックをするわけですね。そして、この条件に合致した場合は「1」のフローへ、それ以外、つまり取得できなかった場合は「else」のフローに進むという分岐になります。

![](images/chapxx-kun432/s097.png)

では、それぞれの結果をSpeakブロックでAlexaに話させましょう。もともとあったSpeakブロックはIfブロックの「1」につないでください。

![](images/chapxx-kun432/s100.png)

もう1つSpeakブロックを追加して、Ifブロックの「else」からつないで、以下のように設定してください。

![](images/chapxx-kun432/s101.png)

最後にAlexa開発者コンソールでテストして、きちんと結果が取れない場合の発話ができていれば完了です。お疲れさまでした。

![](images/chapxx-kun432/s102.png)

//note[undefinedの判定について]{
もちろんストレートにundefindを判定することもできます。VoiceflowのIfブロックにはAdvanced Expressionという記述方式があり、これを使うとプログラム的な書き方で判定可能です。プログラミングに慣れた人はこちらのほうがわかりやすいかもしれません。公式のドキュメントもご覧ください。@<br>{}

Advanced expression （IF and SET blocks） - Voiceflow Docs（英語）@<br>{}
@<href>{https://docs.voiceflow.com/voiceflow-documentation/logic-in-voiceflow/advanced-expression-if-and-set-blocks} 
//}

## Googleスプレッドシートを使う場合の注意

お手軽で便利なGoogleスプレッドシート連携ですが、弱点もあります。

- 個人的な印象ですが、Googleスプレッドシートへのアクセスは、一般的なAPI等へのアクセスに比べると少しレスポンスが遅いと感じます。スキルの中でスプレッドシートへのアクセスを何度も行うと、利用者のスキル利用時のテンポやリズム感を損ねる可能性があることにご注意ください。
- また、Googleスプレッドシートへの高頻度のアクセスは、Googleからアクセス制限される可能性があります。一般的なスキル利用程度であれば問題ないと思いますが、スキルが人気になった場合などはこの制限の対象になる可能性があることにご注意ください。
- Googleスプレッドシートに大量のデータが存在する（行数や列数が多い・セル内の文字数が多い等）場合、レスポンスが遅くなったりデータが取得できなくなったりする場合があります。行・列・セル内データ等の組み合わせにもよるので一概にはいえませんが、多くても1000行未満に抑えることをお勧めします。
- Googleスプレッドシートで検索する場合、検索対象の列は1つしか指定できません。一般的なデータベースで行うような複雑な検索条件は実行できませんのでご注意ください。

上記のような制限に合致したり、Googleスプレッドシートで機能的に物足りなくなったら、AirtableやFirebaseなどの本格的なデータベースを利用することをお勧めします。

- Airtable （@<href>{https://airtable.com/}）
- Firebase （@<href>{https://firebase.google.com/}）

## 最後に

いかがでしょうか。Googleスプレッドシートを使ってデータを読み出すと、一気にデータベースな雰囲気が出てきますね。今回は誌面の都合上、データの参照のみ紹介しましたが、もちろんスプレッドシートへ登録・更新・削除も可能です。 詳しくは以下のサイトにまとめています。またGoogleスプレッドシート連携以外にも多数VoiceflowのTipsなどを紹介していますので、ぜひご覧ください。@<br>{}

- Voiceflow夏休みAdvent Calendar@<br>{}
@<href>{https://qiita.com/kun432/items/666ae13f097004ea7935}
