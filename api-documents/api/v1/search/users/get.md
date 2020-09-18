
# METHOD /api/v1/endpoint
## request parameters
| name | type | importance | description | validation | 
| ---- | ---- | ---------- | ----------- | ---------- | 
| keyword | string | required | 空白区切りのキーワード, _(アンダーバー)がワイルドカード | 10個まで | 
| page_number | integer | optional | 表示するページ(指定がない場合1) |  | 
| max_content | integer | optional | 1ページに表示する量（指定がない場合30） | 1000まで | 
## example requests
```json
{
    "keyword": "test code hoge",
    "page_number": 1,
    "max_content": 50
}
```
## example responses
### SUCCESS
```json
{
    "status": "SUCCESS",
    "body": {
        "results": [
            {
                "name": "takashiii",
                "nickname": "takashiii-nickname",
                "explanation": "aaa",
                "icon": null,
                "is_admin": false
            }
        ],
        "results_size": 1,
        "page_number": 1,
        "hit_total": 1
    }
}
```
### FAILED
```json
{
    "status": "FAILED",
    "body": {
        "message": "too many keywords"
    },
    "errors": [
        {
            "key": "keyword",
            "messages": [
                "too many keywords"
            ],
            "code": null
        }
    ]
}
```
返ってくる可能性のあるerrorsのkeyとmessagesは以下。  
特に記載がない場合statusはFAILED
### エラー
#### keyword
- too many keywords
  - キーワードが10個より多い
