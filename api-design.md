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

1. onetimeを普段は使用(期限は1週間ほど)
2. onetimeの期限が切れていたらsuperトークンを使いonetimeを再発行
3. superトークンも期限が切れたらログインし直し（期限1ヶ月ほど）

### password_reset

1. emailを入力
2. http:hoge.com/password/edit?token=hogefuga?email=hoge%40fugadotcom みたいなアドレスが送られてくる
3. 上記にアクセスするとpublic/password/editにGETリクエストが送られ、jsに変数が渡される
4. パスワードを入力し終えると、APIにreset-tokenとpasswordが渡される
5. tokenを確認し、パスワードを更新後、リセットセッションを削除

### 外部アプリケーション認可

1. 外部アプリケーションからhttps://takashiii-hq.com/api/v1/oauth?appurl=hogehoge.com　みたいなのが渡される
2. 認証なりなんなりの通信を行う
3. https/hogehoge.com/login?token=onetimetoken みたいな感じでワンタイムトークンが渡される
4. https/hogehoge.comでログインする際は、https/takashiii-hq.com/api/v1/"任意のコンテンツ"  にHTTPでtokenを送れば認証され、情報が利用できる
