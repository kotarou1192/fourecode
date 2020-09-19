# POST /api/v1/posts
## request parameters
| name | type | importance | description | validation | 
| ---- | ---- | ---------- | ----------- | ---------- | 
| token.onetime | string | required | ワンタイムトークン |            | 
| value.title | string | required | タイトル | 100文字まで | 
| value.body | string | required | 本文 | 10000文字まで | 
| value.code | string | required | ソースコード | 10000文字まで | 
| value.source_url | string | optional | GitHubなどのURL | 140文字まで。無くても可能。 | 
| value.bestanswer_reward | integer | optional | 回答者に渡すお礼 | 0-500の整数。指定しない場合は100 | 
## example requests
```json
{
    "token": { 
        "onetime": "トークンをここに"
    },
    "value": {
        "title": "title100文字まで", 
        "body": "body1万文字まで",
        "code": "code1万文字まで",
        "source_url": "source_url無くても可", 
        "bestanswer_reward": "reward 無くても可能、最大で500　デフォルトは100"
    } 
}
```
## example responses
### SUCCESS
```json
{
    "status": "SUCCESS",
    "body": "post has been created successfully"
}
```
### FAILED
```json
{
    "status": "FAILED",
    "body": null,
    "errors": [
        {
            "messages": [
                "can't be blank"
            ],
            "key": "title",
            "code": null
        },
        {
            "messages": [
                "can't be blank"
            ],
            "key": "body",
            "code": null
        },
        {
            "messages": [
                "can't be blank"
            ],
            "key": "code",
            "code": null
        }
    ]
}
```
## errors: key & messages
### バリデーションエラー
#### title
- can't be blank
  - 空文字のみで構成されているか、そもそもない
- is too long (maximum is 100 characters)
  - 長過ぎる
#### source_url
- can't be blank
  - 空文字のみで構成されている
- is too long (maximum is 140 characters)
  - 長過ぎる
#### body
- can't be blank
  - 空文字のみで構成されているか、そもそもない
- is too long (maximum is 10000 characters)
  - 長過ぎる
#### code
- can't be blank
  - 空文字のみで構成されているか、そもそもない
- is too long (maximum is 10000 characters)
  - 長過ぎる
#### bestanswer_reward
- must be less than or equal to 500
  - 500より多いとき
- must be greater than or equal to 0
  - 0より小さい時
### エラー
#### token
- onetime token is empty
  - ワインタイムトークンがパラメーターにない
- onetime token is too old
  - ワンタイムトークンの期限が切れている
#### login
- you are not logged in
  - DB上にそのワンタイムトークンが存在しない
