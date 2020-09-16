# PUT /api/v1/account_activations
## request parameters
| name | type | importance | description | validation | 
| ---- | ---- | ---------- | ----------- | ---------- | 
| token | string | required | メールに添付されているアクティベートトークン |  | 
| email | string | required | メールアドレス |            | 
## example requests
```json
{
  "value": {
    "token": "your activate token here",
    "email": "your email address here"
  }
}
```
## example responses
### SUCCESS
```json
{
    "status": "SUCCESS",
    "body": {
        "message": "activated"
    }
}
```
### FAILED
特に記載なしの場合のレスポンスステータス: 400  
```json
{
    "status": "ERROR",
    "message": "invalid activation link",
    "errors": [
        {
            "key": "link",
            "messages": [
                "invalid activation link"
            ],
            "code": null
        }
    ]
}
```
返ってくる可能性のあるerrorsのkeyとmessagesは以下。  
特に記載がない場合statusはFAILED
### エラー
#### link
- invalid activation link
  - メールアドレスとトークンのどちらか一方でも正しくない場合に起きます。
  - 予定としては、登録後1日でトークンが失効するようにしたいので、登録後1日以上放置していた場合にもこれが返ってくるような想定です。
