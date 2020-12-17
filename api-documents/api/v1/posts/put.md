# PUT /api/v1/posts/{id}
## request parameters
| name | type | importance | description | validation | 
| ---- | ---- | ---------- | ----------- | ---------- | 
| value.body | string | required | 本文 | 10000文字まで | 
| value.source_url | string | optional | GitHubなどのURL | 140文字まで。無くても可能。 | 
## example requests
```json
{
    "value": {
        "body": "編集後の本文",
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
## errors: key & messages
### バリデーションエラー
#### source_url
- is too long (maximum is 140 characters)
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
#### id
- not found
  - status: 404
  - 存在しないPostIDを指定したとき
#### authority
- this post is not yours. if you want to edit this post, you should be a admin
  - 他人のポストを削除しようとした時、かつ、Adminでなかった場合（権限不足）
