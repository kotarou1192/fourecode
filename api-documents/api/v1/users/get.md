# GET /api/v1/users/{name}
## request parameters
| name | type | importance | description | 
| ---- | ---- | ---------- | ----------- | 
| token | string | required | onetime token |
## example requests
```json
{
  "token": "onetimeトークンをここに"
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
        "icon": {
            "url": null,
            "thumb": {
                "url": null
            }
        },
        "is_admin": false,
        "is_mypage": true
    }
}
```
### FAILED
特に記載なしの場合のレスポンスステータス: 400  
以下の例は404 user Not Found Error。
```json
{
    "status": "FAILED",
    "body": null,
    "errors": [
        {
            "key": "name",
            "messages": [
                "the user is not found"
            ],
            "code": null
        }
    ]
}
```
返ってくる可能性のあるerrorsのkeyとmessagesは以下。  
特に記載がない場合statusはFAILED
### バリデーションエラー以外
#### name
- the user is not found
  - その名前のユーザーが存在しないとき
