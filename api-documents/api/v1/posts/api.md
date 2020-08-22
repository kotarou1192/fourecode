```json
{
  "status": "SUCCESS or FAILED of ERROR of OLD_TOKEN",
  "body": {
    "この中の値として全て返される。"
  }
}
```
すべてこの形式に沿って返される。

TOKENが古い場合はOLD＿TOKENが帰ってくるので、masterを使って再取得してください。

SUCCESS以外の場合、基本的にbody内のmessageプロパティの値にエラーメッセージが入って帰ってくる。
パスワードが短すぎる場合などのバリデーションエラー時は、ネストされたjsonがmessageの中に入っているので、エラーメッセージをそのまま利用する場合は注意してください。

### GET  
例: /api/v1/posts/1

送信時のパラメータ
```json
{
  "token": "からの場合や、そんざいしないトークンの場合は他人の投稿として表示される"
}
```
成功時のレスポンス
```json
{
  "status": "SUCCESS",
  "body": {
    "title": "タイトル",
    "body": "本文",
    "code": "コード片",
    "bestanswer_reward": "ベストアンサーへのお布施",
    "source_url": "githubとかのURL（ない場合もある）",
    "is_mine": "自分の投稿の場合はtrue",
    "posted_by": {
      "name": "一意な名前（ほぼID)",
      "nickname": "ニックネーム",
      "icon": "アイコンのURL"
    }
  }
}
```

### POST

送信時のJSON  
source_urlとbestanswer_rewardはパラメーター自体無くても可能  

```json
{
  "token": {
    "onetime": "onetime token here"
  },
  "value": {
    "title": "タイトルを入力100文字以内",
    "body": "本文(空・空文字でなければいい)1万文字以内",
    "code": "コード片(空・空文字でなければいい)1万文字以内",
    "source_url": "GithubなどのURL（空も可能）",
    "bestanswer_reward": "ベストアンサーに上げるコイン（空なら100に）"
  }
}
```
