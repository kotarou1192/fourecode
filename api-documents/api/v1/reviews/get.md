# GET /api/v1/posts/{id}/reviews
# GET /api/v1/users/{name}/reviews
上記2つとも同じようなレスポンスを返す
## request parameters
| name | type | importance | description | validation | 
| ---- | ---- | ---------- | ----------- | ---------- | 
| page_number | integer | optional | 表示するページ(指定しなければ1) |            | 
| max_content | integer | optional | 1ページに表示する数(指定しなければ50) |            | 
## example requests
```json
{
  "page_number": "表示するレビューのページ番号. 何も指定しない場合は1",
  "max_content": "1ページに表示するレビュー+レスポンスの数. 何も指定しない場合は50"
}
```
## example responses
### SUCCESS
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

指定したユーザーが存在しない場合と指定したポストが存在しない場合は、レビューが1つもない場合と区別されません。  
よって、その場合はreviewsには空配列が入ります。
