# DELETE /api/v1/posts/{id}
## request parameters
| name | type | importance | description | validation | 
| ---- | ---- | ---------- | ----------- | ---------- | 
## example requests
```json
{
}
```
## example responses
### SUCCESS
```json
{
    "status": "SUCCESS",
    "body": "the post has been deleted successfully"
}
```
### FAILED
```json
{
    "status": "FAILED",
    "body": null,
    "errors": [
        {
            "key": "login",
            "messages": [
                "you are not login"
            ],
            "code": null
        }
    ]
}
```
## errors: key & messages
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
