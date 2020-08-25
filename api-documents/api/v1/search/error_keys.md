### 返ってくる可能性があるerrorsのkey

#### get
キーワードは空白区切りで10個まで。11個以上を送るとエラーが帰ってきます。

ページは空配列が帰ってくるまで無限にめくれます。  
statusの文字列が正しくない場合は無視されます。  
```json
{
    "keyword": "test code hoge", //キーワードを空白区切りで
    "page_number": 1, // ページの指定
    "max_content": 50, // 1ページに表示する量
    "status": "accepting voting resolvedのどれか、もしくは空で指定なし"
}
```

以上のレスポンス

```json
{
    "status": "SUCCESS",
    "body": {
        "results": [
            {
                "id": 120082,
                "title": "test puts hoge",
                "body": "test",
                "code": "code",
                "status": "voting",
                "reward": 100
            },
                // 割愛
            {
                "id": 120033,
                "title": "test99953",
                "body": "test99953",
                "code": "code99953",
                "status": "accepting",
                "reward": 100
            }
        ],
        "results_size": 50,
        "page_number": 1
    }
}
```