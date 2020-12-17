# DELETE /api/v1/auth
## request parameters
| name | type | importance | description | 
| ---- | ---- | ---------- | ----------- | 
## example requests
```json
{
}
```
## example responses
### SUCCESS
レスポンスステータス: 200
```json
{
    "status": "SUCCESS",
    "body": {
        "message": "logout successful"
    }
}
```
### FAILED
特に記載なしの場合のレスポンスステータス: 400  
```json
{
    "status": "FAILED",
    "body": null,
    "errors": [
        {
            "key": "login",
            "messages": [
                "you are not logged in"
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
