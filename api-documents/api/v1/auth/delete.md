# DELETE /api/v1/auth
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
#### login
- you are not logged in
  - パラメーターtokenがない、または、DBに存在しないonetime token
#### token
- onetime token is too old
  - ワンタイムトークンの有効期限が切れている場合
