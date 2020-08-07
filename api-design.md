# api

### 返ってくるjson

- status : SUCCESS | FAILED | ERROR
- body
  - 内容
  
### 送信時に必要なjson
- value
  - 内容
- token
  - super(null可能)
  - onetime(null不可)

### token管理

1. onetimeを普段は使用(期限は1時間ほど)
2. onetimeの期限が切れていたらsuperトークンを使いonetimeを再発行
3. superトークンも期限が切れたらログインし直し
