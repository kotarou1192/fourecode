```json
{
  "status": "SUCCESS or FAILED of ERROR of OLD_TOKEN",
  "body": {
    "この中の値として全て返される。"
  }
}
```
すべてこの形式に沿って返される。

TOKENが古い場合はOLD＿TOKENが帰ってくるので、masterを使って再取得してください。

SUCCESS以外の場合、基本的にbody内のmessageプロパティの値にエラーメッセージが入って帰ってくる。
パスワードが短すぎる場合などのバリデーションエラー時は、ネストされたjsonがmessageの中に入っているので、エラーメッセージをそのまま利用する場合は注意してください。

#### POST /api/v1/posts

送信時のjsonのかたち

```
{
   token: { 
        onetime: トークンをここに
   },
 value: {
        title: title100文字まで, 
        body: body1万文字まで,
        code: code1万文字まで,
        source_url: source_url無くても可, 
        bestanswer_reward: reward 無くても可能、最大で500　デフォルトは100
    } 
}
```

#### GET /api/v1/posts/id

id（数字、1から始まるオートインクリメント）の番号のPOSTを取得します。

送信時パラメーターにTokenがあると、自分の投稿かどうかを判断して返します。

```
{
  token: onetime_token here
}
```

帰ってくるjsonの例

```
{
    "status": "SUCCESS",
    "body": {
        "title": "test",
        "body": "hello",
        "code": "puts 'hello'     hello_world = 'here'",
        "bestanswer_reward": 100,
        "source_url": "",
        "is_mine": false, //自分の投稿かどうか
        "posted_by": {
            "name": "takashiii",
            "nickname": "takashiii",
            "icon": "/uploads/user/icon/8e971bee-c5aa-4007-b1e4-1bb8efb985e4/20200816232527.png"
        }
    }
}
```

#### PUT /api/v1/posts/id

idのポストを編集します。

リクエストのjsonの例

```
{
    "value": {
        "code": "編集後のコードをここに",
        "body": "編集後の本文",
        "source_url": "編集後のソースURLをここに"
    },
    "token":  {
        "onetime": "ここにトークンを"
    }
}
```

#### DELETE /api/v1/posts/id

idのポストを削除します。  
リクエスト時は以下のパラメーターを送信してください。
```
{
  token: onetime_token here
}
```

#### GET /api/v1/search/posts

キーワードは空白区切りで10個まで。11個以上を送るとエラーが帰ってきます。

ページは空配列が帰ってくるまで無限にめくれます。  
statusの文字列が正しくない場合は無視されます。  
```
{
    "keyword": "test code hoge", //キーワードを空白区切りで
    "page_number": 1, // ページの指定
    "max_content": 50, // 1ページに表示する量
    "status": "accepting voting resolvedのどれか、もしくは空で指定なし"
}
```

以上のレスポンス

```
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
