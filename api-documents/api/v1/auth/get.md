# GET /api/v1/auth
このWebAPIは、トークンが有効かどうかを試すテストに使えるかもしれません
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
        "name": "takashiii",
        "nickname": "takashiii-nickname",
        "explanation": "aaa",
        "icon": null,
        "is_admin": false,
        "is_mypage": true
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
### バリデーションエラー以外
#### token
- token is invalid
  - トークンが古かったり不正だったりそもそもなかったり（ログインし直して）
