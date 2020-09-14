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
    "body": {
        "message": "you are not logged in"
    },
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
返ってくる可能性のあるerrorsのkeyとmessagesは以下。  
特に記載がない場合statusはFAILED
### バリデーションエラー以外
#### token
- property onetime of token is empty
  - パラメーターが足りない
- onetime token is too old
  - status: OLD_TOKEN
  - ワンタイムトークンの有効期限が切れている場合
#### login
- you are not logged in
  - DBに存在しないonetime token
