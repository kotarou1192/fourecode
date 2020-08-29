ページは空配列が帰ってくるまで無限にめくれます。  
statusの文字列が正しくない場合は無視されます。  
```json
{
    "keyword": "test code hoge", //キーワードを空白区切りで
    "page_number": 1, // ページの指定（指定がない場合は１）
    "max_content": 50, // 1ページに表示する量（指定がない場合は３０）
}
```

返ってくるJSONの例  
```json
{
    "status": "SUCCESS",
    "body": {
        "results": [
            {
                "name": "takashiii",
                "nickname": "takashiii",
                "explanation": null,
                "icon": "/uploads/user/icon/20200816232527.png",
                "is_admin": false
            }
        ],
        "results_size": 1,
        "page_number": 1,
        "hit_total": 1
    }
}
```
