# PUT /api/v1/password_resets
## request parameters
| name | type | importance | description | validation | 
| ---- | ---- | ---------- | ----------- | ---------- | 
| token | string | required | メールに添付されているURLのクエリパラメータ |            | 
| value.password | string | required | 新しいパスワード | 2時間で期限が切れる | 
## example requests
```json
{
  "token": "password_reset_token",
  "value": {
    "password": "new_password"
  }
}
```
## example responses
### SUCCESS
```json
{
    "status": "SUCCESS",
    "body": {
        "message": "your password has been changed"
    }
}
```
### FAILED
```json
{
    "status": "FAILED",
    "body": null,
    "errors": [
        {
            "key": "invalid_link",
            "messages": [
                "invalid reset link"
            ],
            "code": null
        }
    ]
}
```
## errors: key & messages
### バリデーションエラー
#### password
- is too short (minimum is 6 characters)
  - とても短い
- can't be blank
  - パスワードが空
### エラー
#### invalid_link
- invalid reset link
  - DB上にリセットセッションが存在しない
#### old_link
- the link is too old
  - セッションが古い（制限時間を超えた）
#### password
- password does not exit
  - パラメーターにpasswordがない
