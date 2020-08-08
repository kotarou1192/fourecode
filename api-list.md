# api-list

すべて/api/v1　下の表記である

POST=create
GET=read
PUT=update
DELETE=delete

## user api

#### POST /users
user作成。
パラメーターには
- value
  - name
  - nickname
  - email
  - password

を含めること

#### GET /users/hoge
hogeという名前のuser表示。
パラメーターに

- token
  - onetime

があり、ログインしていた場合は、表示するページがマイページならレスポンスにおいて
- body
  - is_mypage = true

になっている

#### PUT /users/hoge
hogeという名前のuser更新。
パラメーターには
- token
  - onetime

を含めること

#### DELETE /users/hoge
hogeというuser削除。
パラメーターには
- value
  - password
- token
  - onetime

を含めること

#### POST /auth
login
パラメーターには
- value
  - email
  - password
  
を含めること
戻り値のトークンは必ずどちらも控えること。

#### DELETE /auth
logout
パラメーターには
- token
  - onetime

を含めること
