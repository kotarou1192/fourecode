# POST /api/v1/posts/{post_id}/reviews/{review_id}
post_idは実のところ今は何でもよいです（使っていない）が、親のポストを指定したほうが見た目的に良いですし、今後変更があった時に楽かもしれません。  
レビューはreview_idだけで一意になっています。
## request parameters
| name | type | importance | description | validation | 
| ---- | ---- | ---------- | ----------- | ---------- | 
| value.body | string | required |             | 5000文字まで | 
## example requests
```json
{
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
    "body": "the response has been created"
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
- token is invalid
  - トークンが古かったり不正だったりそもそもなかったり（ログインし直して）
#### id
- the review is not found
  - 存在しないreview_idを指定したとき
#### closed
- the post has been closed
  - 状態がcloseなPostに紐づくレビューにリプライしようとしたとき
