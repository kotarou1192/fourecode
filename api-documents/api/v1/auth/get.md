# GET /api/v1/auth
このWebAPIは、トークンが有効かどうかを試すテストに使えるかもしれません
## request parameters
| name | type | importance | description | 
| ---- | ---- | ---------- | ----------- | 
| token | string | required | onetime token | 
## example requests
```json
{
  "token": "your onetime token here"
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
- property onetime of token is empty
  - パラメーターが足りない
- onetime token is too old
  - ワンタイムトークンの有効期限が切れている場合
#### login
- you are not logged in
  - DBに存在しないonetime token
