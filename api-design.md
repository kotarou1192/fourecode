# api

### 返ってくるjson

- status : SUCCESS | FAILED | ERROR | OLD_TOKEN
- body
  - 内容
  
### 送信時に必要なjson(POST, PUT)
- value
  - 内容
- token
  - master(null可能)
  - onetime(null不可)

### 送信時に必要なjson(GET, DELETE)
- token(onetimeトークン)

### token管理

1. onetimeを普段は使用(期限は1週間ほど)
2. onetimeの期限が切れていたらmasterトークンを使いonetimeを再発行
3. masterトークンも期限が切れたらログインし直し（期限1ヶ月ほど）

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
