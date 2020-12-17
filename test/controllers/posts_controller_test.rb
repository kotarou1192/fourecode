require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    @email = 'hoge@email.com'
    @user = User.new(name: 'hoge',
                     nickname: 'hogechan',
                     email: @email,
                     password: 'hogefuga')
    @user.save
    @user.activate
  end

  # test to post

  test 'post should be created' do
    session = create_sessions
    title = 'title'
    body = 'ハロー'
    code = 'puts hello'
    source_url = 'https://github.com/kotarou1192/fourecode'
    reward = 200
    post '/api/v1/posts', params: { value: { title: title, body: body, code: code, source_url: source_url, bestanswer_reward: reward } }, headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    body = JSON.parse(response.body)
    assert body['status'] == 'SUCCESS'
  end

  test 'post with empty token should be failed' do
    title = 'title'
    body = 'ハロー'
    code = 'puts hello'
    source_url = 'https://github.com/kotarou1192/fourecode'
    reward = 200
    post '/api/v1/posts', params: { value: { title: title, body: body, code: code, source_url: source_url, bestanswer_reward: reward } }
    assert response.status == 400
  end

  test 'post with empty body should be failed' do
    session = create_sessions
    title = 'title'
    body = '  '
    code = 'puts hello'
    source_url = 'https://github.com/kotarou1192/fourecode'
    reward = 200
    post '/api/v1/posts', params: { value: { title: title, body: body, code: code, source_url: source_url, bestanswer_reward: reward } }, headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    assert response.status == 400
  end

  test 'post with blank title should be failed' do
    session = create_sessions
    title = '  '
    body = 'ハロー'
    code = 'puts hello'
    source_url = 'https://github.com/kotarou1192/fourecode'
    reward = ''
    post '/api/v1/posts', params: { value: { title: title, body: body, code: code, source_url: source_url, bestanswer_reward: reward } }, headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    assert response.status == 400
  end

  # test to get

  test 'the post should be got' do
    user_post = @user.posts.create(title: 'test', body: 'test')
    get "/api/v1/posts/#{user_post.id}"
    body = JSON.parse(response.body)
    assert body['status'] == 'SUCCESS'

    assert body['body']['body'] == user_post.body
  end

  test 'my post should be mine' do
    session = create_sessions
    user_post = @user.posts.create(title: 'test', body: 'test', code: 'code', source_url: 'test')
    get "/api/v1/posts/#{user_post.id}", headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    body = JSON.parse(response.body)
    assert body['status'] == 'SUCCESS'

    assert body['body']['is_mine'] == true
  end

  # test to update

  test 'should be updated' do
    session = create_sessions
    user_post = @user.posts.create(title: 'test', body: 'test', code: 'code', source_url: 'test')

    put "/api/v1/posts/#{user_post.id}", params: { value: { body: 'body', code: 'edited', source_url: 'edited' } }, headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    body = JSON.parse(response.body)
    assert body['status'] == 'SUCCESS'
  end

  test 'should not be updated' do
    @email2 = 'hoge2@email.com'
    @user2 = User.new(name: 'hoge2',
                      nickname: 'hogechan',
                      email: @email,
                      password: 'hogefuga')
    @user2.save
    @user2.activate

    session = create_sessions
    user_post = @user2.posts.create(title: 'test', body: 'test', code: 'code', source_url: 'test')

    put "/api/v1/posts/#{user_post.id}", params: { value: { body: 'body', code: 'edited', source_url: 'edited' } }, headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    body = JSON.parse(response.body)
    assert body['status'] == 'FAILED'
    assert body['errors'][0]['key'] == 'authority'
  end

  # test to destroy

  test 'should be deleted' do
    session = create_sessions
    user_post = @user.posts.create(title: 'test', body: 'test', code: 'code', source_url: 'test')

    delete "/api/v1/posts/#{user_post.id}", headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    body = JSON.parse(response.body)
    assert body['status'] == 'SUCCESS'
  end

  test 'should not be deleted' do
    @email2 = 'hoge2@email.com'
    @user2 = User.new(name: 'hoge2',
                      nickname: 'hogechan',
                      email: @email,
                      password: 'hogefuga')
    @user2.save
    @user2.activate

    session = create_sessions
    user_post = @user2.posts.create(title: 'test', body: 'test', code: 'code', source_url: 'test')

    delete "/api/v1/posts/#{user_post.id}", headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    body = JSON.parse(response.body)
    assert body['status'] == 'FAILED'
  end

  test 'should be deleted by admin' do
    @email2 = 'hoge2@email.com'
    @user2 = User.new(name: 'hoge2',
                      nickname: 'hogechan',
                      email: @email,
                      password: 'hogefuga')
    @user2.save
    @user2.activate

    session = create_sessions
    user_post = @user2.posts.create(title: 'test', body: 'test', code: 'code', source_url: 'test')

    @user.update(admin: true)

    delete "/api/v1/posts/#{user_post.id}", headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    body = JSON.parse(response.body)
    assert body['status'] == 'FAILED'
  end

  # other
  test 'deleted users post should not be found' do
    session = create_sessions
    user_post = @user.posts.create(title: 'test', body: 'test', code: 'code', source_url: 'test')
    get "/api/v1/posts/#{user_post.id}", headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    assert response.status == 200
    delete "/api/v1/users/#{@user.name}", headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    assert response.status == 200
    get "/api/v1/posts/#{user_post.id}"
  rescue ActiveRecord::RecordNotFound
    assert true
  end
end
