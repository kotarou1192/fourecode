# DELETE /api/v1/posts/{id}
## request parameters
| name | type | importance | description | validation | 
| ---- | ---- | ---------- | ----------- | ---------- | 
| token | string | required | onetime token |            | 
## example requests
```json
{
  "token": "onetime_token here"
}
```
## example responses
### SUCCESS
```json
{
    "status": "SUCCESS",
    "body": "the post has been deleted successfully"
}
```
### FAILED
```json
{
    "status": "FAILED",
    "body": null,
    "errors": [
        {
            "key": "login",
            "messages": [
                "you are not login"
            ],
            "code": null
        }
    ]
}
```
## errors: key & messages
### エラー
#### login
- you are not login
  - トークンが不正だった（DBに存在しないTokenなど）
#### token
- onetime token is too old
  - OnetimeTokenが古かった
#### id
- not found
  - status: 404
  - 存在しないPostIDを指定したとき
