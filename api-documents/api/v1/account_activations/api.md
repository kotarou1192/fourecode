```json
{
  "status": "SUCCESS or ERROR"
  "body": {
    "この中の値として全て返される。"
  }
}
```
すべてこの形式に沿って返される。

SUCCESS以外の場合、基本的にbody内のmessageプロパティの値にエラーメッセージが入って帰ってくる。

### PUT
アカウントのアクティベーション。
リクエストに必要なパラメーターは以下
```json
{
  "value": {
    "token": "your activate token here",
    "email": "your email address here"
  }
}
```
