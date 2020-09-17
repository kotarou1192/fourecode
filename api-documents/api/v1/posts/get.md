# GET /api/v1/posts/{id}
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
    "body": {
        "title": "my first 投稿",
        "body": "my first 投稿の本文",
        "code": "hello world!",
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
    "status": "OLD_TOKEN",
    "body": {
        "message": "onetime token is too old"
    },
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
返ってくる可能性のあるerrorsのkeyとmessagesは以下。  
特に記載がない場合statusはFAILED
### エラー
#### id
- not found
  - status: 404
  - 存在しないPostIDを指定したとき
#### token
- onetime token is too old
  - status: OLD_TOKEN
  - tokenが古い
  