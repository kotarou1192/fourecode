# PUT /api/v1/users/{name}
## request parameters

| name                       | type   | importance      | description                                                                         | validation |
| -------------------------- | ------ | --------------- | ----------------------------------------------------------------------------------- | --- |
| name                       | string | optional        | サービス上で一意な名前。| a-z A-Z 0-9 -で構成すること。長さは最大30まで           | 
| nickname                   | string | optional        | 重複が許されるニックネーム。| a-z A-Z 0-9 -で構成すること。長さは最大30まで       | 
| explanation                | string | optional        | 自己紹介。 | 255文字まで。                                                             | 
| image.base64_encoded_image | string | optional        | アイコン画像。 | 画像サイズは120*120に自動リサイズされる。Base64でエンコードして文字列化して送信すること。 | 
| token.onetime              | string | required        | ワンタイムトークン。 |                                                           |  

## example requests
```json
{
  "token": {
    "onetime": "onetime token here"
    },
  "value": {
    "name": "takashiii-edited",
    "nickname": "takashiii-nickname-edited",
    "explanation": "we are takashiiis",
    "image": {
      "base64_encoded_image": "base64 encoded jpeg/jpg/png/gif"
    }
  }
}
```

## example responses
### SUCCESS
レスポンスステータス: 200

```json
{
    "status": "SUCCESS",
    "body": {
        "message": "user parameters are updated successfully"
    }
}
```

### FAILED
レスポンスステータス: 400  
以下の例はValidationError。
```json
{
    "status": "FAILED",
    "body": null,
    "errors": [
        {
            "messages": [
                "Failed to manipulate with rmagick, maybe it is not an image?"
            ],
            "key": "icon",
            "code": null
        }
    ]
}
```
返ってくる可能性のあるerrorsのkeyとmessagesは以下。  
特に記載がない場合statusはFAILED
### バリデーションエラー時
#### name
- can't be blank
  - 空
- is too long (maximum is 30 characters)
  - 長過ぎる
- is invalid
  - [a-z A-Z 0-9 -] で構成されていない
- has already been taken
  - 既に使われている
#### nickname
- is too long (maximum is 30 characters)
  - 長過ぎる
- is invalid
  - [a-z A-Z 0-9 -] で構成されていない
#### explanation
- can't be blank
  - パラメーターに存在しているのに空
- is too long (maximum is 255 characters)
  - 長過ぎる
#### icon
いろいろなファイルをbase64にエンコードするのが面倒だったため未検証。できればフロント側で画像登録時に検証していただきたく。

### バリデーションエラー以外
#### name 
- invalid user name
  - 存在しないユーザー名を編集しようとしたとき。

#### token 
- onetime token is too old
  - status: OLD_TOKEN
  - ワンタイムトークンが古い。
- property onetime of token is empty
  - ワンタイムトークンが空またはない。

#### login  
- you are not logged in
  - ログインしていない場合。

#### admin  
status: ERROR
- you are not admin
  - adminではないのに人のパラメーターを編集しようとした場合。  
