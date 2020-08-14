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

### POST

パスワードリセットをリクエストする
パラメーターの内容

```json
{
  "value": {
    "email": "target_account's_email"
  }
}
```

### PUT

パスワードをリセットする
リクエストに必要なプロパティは以下

```json
{
  "token": "password_reset_token",
  "value": {
    "password": "new_password"
  }
}
```
