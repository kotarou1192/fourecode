```json
{
  "status": "SUCCESS or FAILED of ERROR of OLD_TOKEN"
  "body": {
    "この中の値として全て返される。"
  }
}
```
すべてこの形式に沿って返される。

SUCCESS以外の場合、基本的にbody内のmessageプロパティの値にエラーメッセージが入って帰ってくる。
パスワードが短すぎる場合などのバリデーションエラー時は、ネストされたjsonがmessageの中に入っているので、エラーメッセージをそのまま利用する場合は注意してください。


### GET
自分のユーザー情報取得。
リクエストに必要なパラメーターは以下
```json
{
  "token": "onetime token here"
}
```

responseのjsonのbody内の値
```json
{
  "name": "your name",
  "nickname": "your nickname",
  "explanation": "自己紹介",
  "icon": "アイコンのURL",
  "is_admin": "adminかどうか",
  "is_mypage": "true(自分のページなので当たり前。おそらく死にパラメータ)",
}
```

### POST
ログイン。
tokenの中に要素masterがある場合PUTにリダイレクトされる仕様。パラメーターにそれが存在しなければ普通にログインが出来る。

リクエストに必要なパラメーターは以下
```json
{
  "value": {
    "email": "your email",
    "password": "your password",
  }
}
```

### PUT
onetimeトークン再取得。

リクエストに必要なパラメーターは以下

```json
{
  "token": {
    "master": "your master token here"
  }
}
```

### DELETE
すべてのデバイスからログアウト

リクエストに必要なパラメーターは以下。

```json
{
  "token": "your onetime token here"
}
```
