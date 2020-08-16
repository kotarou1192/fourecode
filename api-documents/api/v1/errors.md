### 返ってくるエラーの形

```json
{
  "status": "ERROR | FAILED | OLD_TOKEN",
  "message": "message",
  "errors": [
      {
          "key": "link",
          "messages": [
              "invalid activation link"
          ],
          "code": null
      }
  ]
}
```

errorsは配列で返ってくる点に注意。

keyにはエラーの要因が、メッセージにはエラーメッセージが帰ってくる。
