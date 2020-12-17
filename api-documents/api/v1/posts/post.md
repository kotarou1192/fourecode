# POST /api/v1/posts
## request parameters
| name | type | importance | description | validation | 
| ---- | ---- | ---------- | ----------- | ---------- | 
| value.title | string | required | タイトル | 100文字まで | 
| value.body | string | required | 本文 | 10000文字まで | 
## example requests
```json
{
    "token": { 
        "onetime": "トークンをここに"
    },
    "value": {
        "title": "title100文字まで", 
        "body": "body1万文字まで"
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
#### body
- can't be blank
  - 空文字のみで構成されているか、そもそもない
- is too long (maximum is 10000 characters)
  - 長過ぎる
### エラー
#### token
- token is invalid
  - トークンが古かったり不正だったりそもそもなかったり（ログインし直して）
