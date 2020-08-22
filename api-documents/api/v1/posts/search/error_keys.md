### 返ってくる可能性があるerrorsのkey

#### POST
バリデーションエラー
body, code, bestanswer_reward(コインの数値が異常), source_url, poor(コイン不足,コイン未実装のためまだ返ってこない)

トークンのエラー  
tokenが古いor不正な（存在しない）トークン -> login  
パラメーターにtoken:onetimeがそもそもない -> token  

#### GET
トークンのエラー
tokenが古い場合のみ -> token  
存在しない記事IDをリクエストした場合 -> 404が帰るだけ  
