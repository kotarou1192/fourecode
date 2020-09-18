# POST /api/v1/password_resets
## request parameters
| name | type | importance | description | validation | 
| ---- | ---- | ---------- | ----------- | ---------- | 
| value.email | string | required | email |            | 
## example requests
```json
{
  "value": {
    "email": "target_account's_email"
  }
}
```
## example responses
### SUCCESS
```json
{
    "status": "SUCCESS",
    "body": {
        "message": "password reset mail has been sent"
    }
}
```
### FAILED
```json
{
    "status": "FAILED",
    "body": null,
    "errors": [
        {
            "key": "email",
            "messages": [
                "the email address does not exist"
            ],
            "code": null
        }
    ]
}
```
## errors: key & messages
### エラー
#### account
- account is not activated
  - そのaccountがアクティベートされていない場合
#### email
- the email address does not exist
  - そのemailがDBに存在しない場合
