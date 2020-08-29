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
hogeという名前のUser表示。
返ってくるJsonは以下の通り。

```json
{
    "status": "SUCCESS",
    "body": {
        "name": "takashiii",
        "nickname": "takashiii",
        "explanation": null,
        "icon": {
            "url": "/uploads/user/icon/8e971bee-c5aa-4007-b1e4-1bb8efb985e4/20200816232527.png",
            "thumb": {
                "url": "/uploads/user/icon/8e971bee-c5aa-4007-b1e4-1bb8efb985e4/thumb_20200816232527.png"
            }
        },
        "is_admin": false,
        "is_mypage": false
    }
}
```

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
