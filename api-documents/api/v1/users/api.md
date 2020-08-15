返ってくるjsonは
```json
{
  "status": "SUCCESS or FAILED of ERROR of OLD_TOKEN"
  "body": {
    "この中の値として全て返される。"
  }
}
```
すべてこの形式に沿って返される。

成功した場合はstatusはSUCCESS, それ以外は基本的にFAILEDまたはERRORが返ってくる。
FAILEDまたはERRORの場合、body内のmessageプロパティの値に英文のメッセージが入って返ってくる。
トークンをもたせていた場合、onetimeトークンが古かったらstatusとしてOLD_TOKENが帰ってくる。
パスワードが短すぎる場合などのバリデーションエラー時は、ネストされたjsonがmessageの中に入っているので、エラーメッセージをそのまま利用する場合は注意してください。

#### POST /users
user作成。
パラメーターには
```json
{
  "value": {
    "name": "your name",
    "nickname": "your nickname 作成時の必要項目から削除予定",
    "email": "your email",
    "password": "your password",
  }
}
```

を含めること

#### GET /users/hoge
hogeという名前で前方一致検索。
返ってくるJsonは以下の通り。

```json
[{
  "name": "一意な名前（ほぼID)",
  "nickname": "ニックネーム",
  "explanation": "自己紹介",
  "icon": "アイコンのURL",
  "is_admin": "その人が管理者かどうか",
  "is_mypage": "自分のページかどうか",
}]
```
配列である点に注意。

パラメーターに

```json
{
  "token": "onetimeトークンをここに"
}
```

があり、ログインしていた場合は、配列の要素の情報が自分のものならレスポンスにおいて
- body
  - is_mypage = true

になっている

#### PUT /users/hoge
hogeという名前のuser更新。
パラメーターには
```json
{
  "token": {
    "onetime": "onetime token here"
  },
  "value": {
    "image": {
      "name": "死にパラメータ。使っていない。",
      "base64_encoded_image": "使いたいアイコンをbase64でエンコードした文字列をここに置く"
    },
    "explanation": "自己紹介",
    "name": "自分のiDみたいなもの",
    "nickname": "ニックネーム",
  }
}
```

を含めること

#### DELETE /users/hoge
hogeというuser削除。
パラメーターには
```json
{
  "token": "onetimeトークンをここに"
}
```
を含めること
