# Googleスプレッドシートと連携してみよう

VoiceflowのGoogleスプレッドシート連携機能を使うと、普段お使いのExcelと同じ使い勝手で使える簡易なデータベースとして利用できますので、スキル開発の幅が一気に広がります。ぜひ活用してワンランク上のスキルを作ってみましょう。

## スプレッドシートのデータをランダムに呼び出す

最初に、VoiceflowのGoogleスプレッドシート連携の基本的な使い方を学びつつ、シートからランダムにデータを取り出すというのをやってみましょう。サンプルとして、Googleスプレッドシートに登録してあるオススメのレシピとその材料をランダムに教えてくれるスキルを作っていきたいと思います。

最初に、お持ちのGoogleアカウントでGoogleスプレッドシートにログインし、以下のようなスプレッドシートを作成してください。

![Googleスプレッドシート上のレシピデータ](images/chapxx-kun432/s009.png)

- スプレッドシート名は「我が家のレシピデータ」とします。
- シート名（下のタブ）は「レシピ一覧」とします。
- 以下のようなデータを入力します。
  - A1に```recipe_name```、B1に```recipe_content```と入力します。1行目が必ず見出しの行となります。日本語での指定はできませんのでご注意ください。
  - 2行目以降は、A列にレシピ名、B列に材料名を入力していきます。

次に、Voiceflow側で以下のようなプロジェクトを作成して、ブロックを配置してください。

![プロジェクト](images/chapxx-kun432/s009.png)

- プロジェクト名は「我が家のレシピ」とします。言語は「Japanese(ja-JP)」のみを選択してください。
- プロジェクトが作成されたら、Speakブロックを1つ配置し、HomeブロックのStartと線でつなげます。
- Speakブロックの中は以下を入力してください。最後の```<audio src=・・・```のところは、Alexa Skills Kitサウンドライブラリを使って音楽を流すようにしています。
```
我が家のレシピスキルにようこそ。このスキルではおすすめのレシピをランダムに教えるよ。今日のおすすめは、<audio src="soundbank://soundlibrary/ui/gameshow/amzn_ui_sfx_gameshow_intro_01"/>
```

Googleスプレッドシートとの連携は「Integrationブロック」を使います。左のBlocksメニューにあるAdvancedから、Integrationブロックをドラッグ・アンド・ドロップでSpeakブロックの右側に配置して、線でつないでください。

![Integrationブロックの配置](images/chapxx-kun432/s002.png)

右側に表示されるIntegrationブロックの設定で、「Google Sheets」（Googleスプレッドシートのことを英語ではGoogle Sheetsと呼びます）をクリックします。

![Integrationブロックの設定①](images/chapxx-kun432/s002-2.png)

まず、シートのデータをどうしたいのか？を選択します。 選択できるのは以下の4つです。

![Integrationブロックの設定②](images/chapxx-kun432/s003.png)

- Retrieve Data（データの取得）
- Create Data（データの登録）
- Update Data（データの更新）
- Delete Data（データの削除）

このスキルでは、レシピ名と材料名のデータをGoogleスプレッドシートから取り出しますので、「Retrieve Data」クリックします。

![Integrationブロックの設定③](images/chapxx-kun432/s003-2.png)

次に、GoogleスプレッドシートへアクセスするためにGoogleアカウントとの紐付けを行います。「＋Add User」をクリックします。

![Integrationブロックの設定④](images/chapxx-kun432/s004.png)

はじめてアカウント連携を行う場合は以下のようにGooogleへのログインを促す画面が表示されます。「Login with Google」をクリックします。

![Integrationブロックの設定⑤](images/chapxx-kun432/s005.png)

Googleアカウントの選択画面が表示されますので、Googleスプレッドシートを作成したアカウントを選択します。アカウント・パスワードを入力する画面が表示される場合もあります。その場合はお手持ちのGoogleアカウントとパスワードでログインしてください。

![Integrationブロックの設定⑥](images/chapxx-kun432/s006.png)

初回のみ、VoiceflowからGoogleスプレッドシートへのアクセス許可設定を行う必要があります。「許可」をクリックします。

![Integrationブロックの設定⑦](images/chapxx-kun432/s007.png)

以下のように表示されればGoogleアカウントとの紐付けは完了しています。「Using Sheet」をクリックして次に進みます。

![Integrationブロックの設定⑧](images/chapxx-kun432/s008.png)

「Using Sheet」では、Voiceflowからアクセスするスプレッドシートを選択します。「Spreadsheet」でスプレッドシート名、「Sheet」でシート名（下のタブ名）をそれぞれリストから選択します。今回、最初に作成したスプレッドシートの場合だと、「Spreadsheet」に「我が家のレシピデータ」、「Sheet」に「レシピデータ一覧」を選択します。

![Integrationブロックの設定⑨](images/chapxx-kun432/s011.png)

スプレッドシートの選択が完了すると、「With Settings」が表示されます。ここは後で説明しますので、とりあえず左側の「Column」にリストから「Row Number」を選択してください。右側の「Value to Match」は何も入力せずに「Next」をクリックします。

![Integrationブロックの設定⑩](images/chapxx-kun432/s035.png)

## Googleスプレッドシートを使う場合の注意

お手軽で便利なGoogleスプレッドシート連携ですが、弱点もあります。

- 個人的な印象ですが、Googleスプレッドシートへのアクセスは、一般的なAPI等へのアクセスに比べると少しレスポンスが遅いと感じます。スキルの中でスプレッドシートへのアクセスを何度も行うと、利用者のスキル利用時のテンポやリズム感を損ねる可能性があることにご注意ください。
- また、Googleスプレッドシートへの高頻度のアクセスは、Googleからアクセス制限される可能性があります。一般的なスキル利用程度であれば問題ないと思いますが、スキルが人気になった場合などはこの制限の対象になる可能性があることにご注意ください。
- Googleスプレッドシートに大量のデータが存在する（行数や列数が多い、セル内の文字数が多い、等）場合、レスポンスが遅くなったり、データが取得できなくなったりする場合があります。行・列・セル内データ等の組み合わせにもよるので一概には言えませんが、多くても1000行未満に抑えることをオススメします。
- Googleスプレッドシートで検索する場合、検索対象の列は1つしか指定できません。一般的なデータベースで行うような複雑な検索条件は実行できませんのでご注意ください。

上記のような制限に合致したり、Googleスプレッドシートで機能的に物足りなくなった場合、AirtableやFirebaseなどの本格的なデータベースを利用することをオススメします。

- Airtable (https://airtable.com/)
- Firebase (https://firebase.google.com/)

また、これらの使い方について

## まとめ

いかがでしょうか？今回は取り上げませんでしたが、スプレッドシートへのデータの登録・更新・削除ももちろん可能です。

## 最後に

私のブログでいくつかGoogleスプレッドシート関連のチュートリアル的な記事を書いていますのでご紹介します。よろしければご覧ください。

- 「Voiceflow Tips #7 Googleスプレッドシート連携で作る豆知識スキル」@<br>{}[https://kun432.hatenablog.com/entry/voiceflow_tips_7_fact_skill_integrated_with_google_sheets](https://kun432.hatenablog.com/entry/voiceflow_tips_7_fact_skill_integrated_with_google_sheets)

初歩のAlexaスキル開発のサンプルとしてもよく取り上げられている「豆知識」スキルをGoogleスプレッドシートと連携させて作ります。Googleスプレッドシート側に豆知識の「ネタ」をたくさん登録しておいて、ランダムに呼び出すというものです。

- 「Voiceflow Tips #12 Googleスプレッドシート連携で作るゼロカロリースキル 〜スプレッドシートの検索〜」@<br>{}(https://kun432.hatenablog.com/entry/voiceflow_tips_12_retrieve_from_google_spreadsheet)
- 「Voiceflow Tips #14 Googleスプレッドシート連携で作るゼロカロリースキル 〜スプレッドシートへの登録〜」@<br>{}(https://kun432.hatenablog.com/entry/voiceflow_tips_14_insert_data_into_google_sheets)
- 「Voiceflow Tips #18 Googleスプレッドシート連携で作るゼロカロリースキル 〜スプレッドシートの更新〜」@<br>{}(https://kun432.hatenablog.com/entry/voiceflow_tips_18_update_data_with_google_sheets)
- 「Voiceflow Tips #19 Googleスプレッドシート連携で作るゼロカロリースキル 〜スプレッドシートの削除〜」@<br>{}(https://kun432.hatenablog.com/entry/voiceflow_tips_19_delete_data_with_google_sheets)

2019年のAlexaスキルハッカソン大阪で話題になっていた、がおまるさん（@gaomar）の「ゼロカロリースキル」をGoogleスプレッドシート連携だけで作るというものです。データベースの基本となる、一連のCRUD操作（Create:登録、 Retrieve:参照、Update:更新、Delete:削除）を4回に分けて紹介しています。

- 「Voiceflow TIPS #29 Airtableと組み合わせて、もっとデータベースらしく」@<br>{}(https://kun432.hatenablog.com/entry/voiceflow_tips_29_integration_with_airtable)

Voiceflowでは物足りない場合、

- 「Voiceflow TIPS #35 Firebase RealtimeDatabaseでデータを管理する」@<br>{}(https://kun432.hatenablog.com/entry/voiceflow_tips_35_integration_with_firebase_realtime_database)
