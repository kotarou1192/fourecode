
#### get /search/posts

keyword: キーワードが11個以上あるとき

#### get /posts/id

token: tokenが古い場合（不正なトークン・トークンがパラメーターにない場合は無視されて何も起きません）

status404: そのidのポストが見つからない場合

#### put /posts/id

status404: そのidのポストが見つからない場合

token: tokenがない・古いとき（statusがOLD_TOKENの場合はトークンリフレッシュが必要)

login: トークンが不正なとき(logoutしたのに古いトークンを送りつけたときなど)

authority: 自分の投稿じゃない・管理者ではない場合

バリデーションエラー: 各パラメーターの名前がそのままキーに

#### post /posts

token: tokenがない・古いとき（statusがOLD_TOKENの場合はトークンリフレッシュが必要)

login: トークンが不正なとき(logoutしたのに古いトークンを送りつけたときなど)

authority: 自分の投稿じゃない・管理者ではない場合

バリデーションエラー: 各パラメーターの名前がそのままキーに

#### delete /posts/id

token: tokenが古い場合（不正なトークン・トークンがない場合は無視されて何も起きません）

status404: そのidのポストが見つからない場合

authority: 自分の投稿じゃない・管理者ではない場合
