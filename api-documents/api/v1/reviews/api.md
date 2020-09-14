#### post /api/v1/posts/id/reviews

必要なparameterの例

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

成功すればbodyのstatusにSUCCESSが、それ以外はFAILEDが入る。詳細はErrorsのKey（別途ドキュメント）を参照のこと。

#### get /api/v1/posts/id/reviews
#### get /api/v1/users/name/reviews

required params
```json
{
  "page_number": "表示するレビューのページ番号. 何も指定しない場合は1",
  "max_content": "1ページに表示するレビュー+レスポンスの数. 何も指定しない場合は50"
}
```

URLのidは投稿のID  
URLのnameはユーザーの名前  
log-inしていなくても見れる。

##### レスポンスの中身の例

```json
{
    "status": "SUCCESS",
    "body": {
        "reviews": [
            {
                "id": 1,
                "body": "review_body",
                "created_at": "2020-09-04T10:07:43.484Z",
                "thrown_coins": 0,
                "reviewer": {
                    "name": "takashiii",
                    "nickname": "takashiii",
                    "icon": null
                },
                "responses": [
                    {
                        "id": 2,
                        "body": "reply",
                        "created_at": "2020-09-04T10:09:18.365Z",
                        "thrown_coins": 0,
                        "responder": {
                            "name": "takashiii",
                            "nickname": "takashiii",
                            "icon": null
                        }
                    },
                    {
                        "id": 3,
                        "body": "reply2",
                        "created_at": "2020-09-04T10:13:08.260Z",
                        "thrown_coins": 0,
                        "responder": {
                            "name": "takashiii",
                            "nickname": "takashiii",
                            "icon": null
                        }
                    }
                ]
            },
            {
                "id": 4,
                "body": "review_body",
                "created_at": "2020-09-04T15:12:49.789Z",
                "thrown_coins": 0,
                "reviewer": {
                    "name": "takashiii",
                    "nickname": "takashiii",
                    "icon": null
                },
                "responses": []
            }
        ],
        "total_contents_count": 4,
        "page_number": 1
    }
}
```