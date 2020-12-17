# POST /api/v1/auth
## request parameters
| name | type | importance | description | validation | 
| ---- | ---- | ---------- | ----------- | ---------- | 
| email | string | required | ログインするアカウントのメールアドレス |            | 
| password | string | required | ログインするアカウントのパスワード |            | 
## example requests
```json
{
  "value": {
    "email": "email@email.com",
    "password": "your-password!"
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
        "token": "your token"
    }
}
```
### FAILED
レスポンスステータス: 400  
セキュリティ上の都合によりどこが間違っていたかの情報は返さない  
```json
{
    "status": "FAILED",
    "body": null
}
```
