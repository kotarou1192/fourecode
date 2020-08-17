### 返ってくるエラーの形

```json
{
  "status": "ERROR | FAILED | OLD_TOKEN",
  "message": "message",
  "errors": [
      {
          "key": "タイプ(個別に言及あり)",
          "messages": [
              "メッセージの配列"
          ],
          "code": null
      }
  ]
}
```

errorsは配列で返ってくる点に注意。

keyにはエラーの要因が、メッセージにはエラーメッセージが帰ってくる。
