# DELETE /api/v1/users/{name}
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
        "message": "user is deleted successfully"
    }
}
```
### FAILED
特に記載なし: レスポンスステータス: 400  
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
#### name 
- invalid user name
  - 存在しないユーザー名を編集しようとしたとき。

#### token 
- onetime token is too old
  - ワンタイムトークンが古い。
- property onetime of token is empty
  - ワンタイムトークンが空またはない。

#### login  
- you are not logged in
  - ログインしていない場合。

#### admin  
- you are not admin
  - adminではないのに人のパラメーターを編集しようとした場合。  
