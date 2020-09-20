# POST /api/v1/posts/{id}/reviews
## request parameters
| name | type | importance | description | validation | 
| ---- | ---- | ---------- | ----------- | ---------- | 
| token.onetime | string | required |             |            | 
| value.body | string | required |             | 5000文字まで | 
## example requests
```json
{
   "token": {
             "onetime": "your onetime token here"
   },
   "value": {
       "body": "your review body here"
   }
}
```
## example responses
### SUCCESS
```json
{
    "status": "SUCCESS",
    "body": "the review has been created successfully"
}
```
### FAILED
```json
{
    "status": "FAILED",
    "body": null,
    "errors": [
        {
            "messages": [
                "can't be blank"
            ],
            "key": "body",
            "code": null
        }
    ]
}
```
## errors: key & messages
### バリデーションエラー
#### body
- is too long (maximum is 5000 characters)
  - 文字が多すぎる
- can't be blank
  - 空白文字のみか、そもそも文字がない場合
### エラー
#### token
- onetime token is empty
  - ワインタイムトークンがパラメーターにない
- onetime token is too old
  - ワンタイムトークンの期限が切れている
#### login
- you are not logged in
  - DB上にそのワンタイムトークンが存在しない
#### id
- the post is not found
  - 存在しないpost_idを指定したとき
#### closed
- the post has been closed
  - 状態がcloseなPostにレビューしようとしたとき
