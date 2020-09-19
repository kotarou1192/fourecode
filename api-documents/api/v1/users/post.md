# POST /api/v1/users
## request parameters

| name                       | type   | importance      | description                                                                         | validation | 
| -------------------------- | ------ | --------------- | ----------------------------------------------------------------------------------- | --- |
| name                       | string | required        | サービス上で一意な名前。           | a-z A-Z 0-9 -で構成すること。長さは最大30まで |
| nickname                   | string | optional        | 重複が許されるニックネーム。       | a-z A-Z 0-9 -で構成すること。長さは最大30まで。空白、もしくは無ければnameと同じになる。|
| email                      | string | required        | メールアドレス。                                     | 重複は許されない。255文字まで。 |
| password                   | string | required        | パスワード。                                                             | 最小6文字。 |
| explanation                | string | optional        | 自己紹介。                                                             | 255文字まで。 |
## example requests
```json
{
  "value": {
    "name": "takashiii",
    "nickname": "takap",
    "email": "takashiii@example.com",
    "password": "my_password!",
    "explanation": "hello, i am takashiii"
  }
}
```

## example responses
### SUCCESS
レスポンスステータス: 200
確認メールが登録されたメールアドレスへ送信される。
```json
{
    "status": "SUCCESS",
    "body": {
        "message": "activation mail has been sent"
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
                "has already been taken"
            ],
            "key": "name",
            "code": null
        },
        {
            "messages": [
                "has already been taken"
            ],
            "key": "email",
            "code": null
        }
    ]
}
```
## errors: key & messages
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
#### email
- can't be blank
  - 空
- is too long (maximum is 255 characters)
  - 長過ぎる
- is invalid
  - メールアドレスの形式がおかしい
- has already been taken
  - 既に使われている
#### password
- can't be blank
  - 空
- is too short (minimum is 6 characters)
  - 短すぎる
#### explanation
- can't be blank
  - パラメーターに指定しているのに空
- is too long (maximum is 255 characters)
  - 長過ぎる
