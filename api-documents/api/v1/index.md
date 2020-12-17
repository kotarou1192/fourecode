## Four-E-CodeのAPIドキュメント

リクエストの結果がSUCCESSの場合：　status=200  
その他の場合は特に記載がない場合についてstatus=400で帰ってきます。

リクエストヘッダーにトークンを含めてください。

```
Authorization: Bearer Your-Token-Here
```

例

```
Authorization: Bearer bbf3394d-23d4-4487-bac1-27e638349bab_9761f9b143ce385443b165e...
```

成功時、bodyの中身にあるstatusにはSUCCESSが、それ以外はFAILEDが入ります。

### WebAPIs
- [users](./users/index.md)
- [auth](./auth/index.md)
- [account_activations](./account_activations/index.md)
- [password_resets](./password_resets/index.md)
- [posts](./posts/index.md)
- [reviews](./reviews/index.md)
- [responses](./responses/index.md)
- [search/posts](./search/posts/index.md)
- [search/users](./search/users/index.md)
