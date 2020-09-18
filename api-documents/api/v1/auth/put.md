# PUT /api/v1/auth
## request parameters
| name | type | importance | description | 
| ---- | ---- | ---------- | ----------- | 
| token.master | string | required | master token | 
## example requests
```json
{
  "token": {
    "master": "master token here"
        }
}
```
## example responses
### SUCCESS
レスポンスステータス: 200
```json
{
    "status": "SUCCESS",
    "body": {
        "token": {
            "onetime": "new onetime token here"
        }
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
返ってくる可能性のあるerrorsのkeyとmessagesは以下。  
特に記載がない場合statusはFAILED
### バリデーションエラー以外
#### token
- property master of token is empty
  - パラメーター(master token)がない
- master token is too old
  - マスタートークンが古い
#### login
- you are not logged in
  - マスタートークンが不正(DBに存在しないトークン)
