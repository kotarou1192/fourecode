# GET /api/v1/posts/{id}
## request parameters
| name | type | importance | description | validation | 
| ---- | ---- | ---------- | ----------- | ---------- | 
## example requests
```json
{
}
```
## example responses
### SUCCESS
```json
{
    "status": "SUCCESS",
    "body": {
        "title": "my first 投稿",
        "body": "my first 投稿の本文",
        "state": "open",
        "bestanswer_reward": 390,
        "source_url": "https://github.com/kotarou1192/fourecode",
        "is_mine": false,
        "posted_by": {
            "name": "takashiii",
            "nickname": "takashiii",
            "icon": null
        }
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
            "key": "token",
            "messages": [
                "onetime token is too old"
            ],
            "code": null
        }
    ]
}
```
## errors: key & messages
### エラー
#### id
- not found
  - status: 404
  - 存在しないPostIDを指定したとき

#### token
- token is invalid
  - トークンが古かったり不正だったりそもそもなかったり（ログインし直して）
  