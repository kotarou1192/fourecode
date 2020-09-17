# PUT /api/v1/posts/{id}
## request parameters
| name | type | importance | description | validation | 
| ---- | ---- | ---------- | ----------- | ---------- | 
| token.onetime | string | required | ワンタイムトークン |            | 
| value.body | string | required | 本文 | 10000文字まで | 
| value.code | string | required | ソースコード | 10000文字まで | 
| value.source_url | string | optional | GitHubなどのURL | 140文字まで。無くても可能。 | 
## example requests
```json
{
    "value": {
        "code": "編集後のコードをここに",
        "body": "編集後の本文",
        "source_url": "編集後のソースURLをここに"
    },
    "token":  {
        "onetime": "ここにトークンを"
    }
}
```
## example responses
### SUCCESS
```json
{
    "status": "SUCCESS",
    "body": "the post is updated successfully"
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
            "key": "body",
            "code": null
        },
        {
            "messages": [
                "can't be blank"
            ],
            "key": "code",
            "code": null
        },
        {
            "messages": [
                "can't be blank"
            ],
            "key": "source_url",
            "code": null
        }
    ]
}
```
返ってくる可能性のあるerrorsのkeyとmessagesは以下。  
特に記載がない場合statusはFAILED
### バリデーションエラー
#### source_url
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
### エラー
#### token
- onetime token is empty
  - ワインタイムトークンがパラメーターにない
- onetime token is too old
  - status: OLD_TOKEN
  - ワンタイムトークンの期限が切れている
#### login
- you are not logged in
  - DB上にそのワンタイムトークンが存在しない
#### id
- not found
  - status: 404
  - 存在しないPostIDを指定したとき