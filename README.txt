デジタルサイネージ 操作ガイド
================================

■ ファイル構成
index.html              GitHub Pagesで再生するサイネージ
admin.html              独立した設定・管理ページ
signage-playlist.json   再生順、素材名、秒数を保存する設定ファイル
画像・映像ファイル      index.html と同じフォルダーに置く

■ 再生
GitHub Pagesで公開された index.html を開くと再生が始まります。
設定を取得するため、ローカルで確認するときもWebサーバー経由で開いてください。
動画・画像は設定JSONに記載したファイル名を使い、index.html と同じ階層から読み込みます。

サイネージ上をクリックするかスペースキーを押すと、次の項目へ進みます。
通常は設定された順序で自動再生を繰り返します。

■ 管理
admin.html を開きます。サイネージから管理ページへ移動する必要はありません。

・種類: 画像、映像、時計
・素材: ファイル名だけ入力。素材は index.html と同じ階層に置く
・順番: 左側の番号をドラッグするか、上下矢印を押す
・秒数: 画像は初期値15秒。映像・時計は空欄で動画の実尺を使う
・削除: ごみ箱アイコン
・追加: 「＋ 項目を追加」

■ GitHubへ設定を反映
1. GitHub Pagesで admin.html を開きます。公開中の signage-playlist.json が読み込まれます。
2. GitHub Desktopで作業するPCのリポジトリ内にある signage-playlist.json を「設定JSONを開く」から選びます。
3. 順番、ファイル名、秒数を編集し、「JSONに保存」を押して同じファイルへ保存します。
4. GitHub Desktopで signage-playlist.json の変更をcommitし、pushします。
5. GitHub Pagesへ反映されたら index.html が新しい順番で再生します。

File System Access APIに対応するブラウザーでは、JSONを開いた後、選んだ同じファイルへ保存できます。
非対応ブラウザーではJSONがダウンロードされるため、リポジトリ内の signage-playlist.json を置き換えてください。

設定JSONには素材ファイル自体は含まれません。新しい画像や動画もリポジトリに追加してcommit/pushしてください。
設定やメディアはブラウザーのローカルストレージには保存されません。