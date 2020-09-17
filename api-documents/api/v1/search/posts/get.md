# GET /api/v1/
## request parameters
| name | type | importance | description | validation | 
| ---- | ---- | ---------- | ----------- | ---------- | 
| keyword | string | required | 空白区切りのキーワード, _(アンダーバー)がワイルドカード | 10個まで | 
| page_number | integer | optional | 表示するページ(指定がない場合1) |  | 
| max_content | integer | optional | 1ページに表示する量（指定がない場合30） | 1000まで | 
| status | [closed] or [open] or [""] | optional | Postの状態で絞り込み | closed, open以外は無視される | 
| author | string | optional | postを書いた人を指定 |  | 
## example requests
```json
{
    "keyword": "test code hoge",
    "page_number": 1,
    "max_content": 50,
    "status": ""
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
                "id": 103,
                "title": "mollit anim id est laborum.",
                "body": "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                "code": "ddddd",
                "status": "open",
                "reward": 100,
                "author": {
                    "name": "takashiii"
                }
            },
            {
                "id": 102,
                "title": "mollit anim id est laborum.",
                "body": "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                "code": "ddddd",
                "status": "open",
                "reward": 100,
                "author": {
                    "name": "takashiii"
                }
            },
            {
                "id": 101,
                "title": "mollit anim id est laborum.",
                "body": "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                "code": "ddddd",
                "status": "open",
                "reward": 100,
                "author": {
                    "name": "takashiii"
                }
            },
            {
                "id": 100,
                "title": "mollit anim id est laborum.",
                "body": "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                "code": "ddddd",
                "status": "open",
                "reward": 100,
                "author": {
                    "name": "takashiii"
                }
            }
        ],
        "results_size": 4,
        "page_number": 1,
        "hit_total": 100
    }
}
```
### FAILED
```json
{
    "status": "ERROR",
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
