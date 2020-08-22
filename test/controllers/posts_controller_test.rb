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

  def create_sessions
    master_session = @user.master_session.create
    onetime_session = master_session.onetime_session.new
    onetime_session.user = @user
    onetime_session.save
    [master_session, onetime_session]
  end

  # test to post

  test 'post should be created' do
    m, o = create_sessions
    title = 'title'
    body = 'ハロー'
    code = 'puts hello'
    source_url = 'https://github.com/kotarou1192/fourecode'
    reward = 200
    post '/api/v1/posts', params: { token: { onetime: o.token }, value: { title: title, body: body, code: code, source_url: source_url, bestanswer_reward: reward } }
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

  test 'post with too many coins should be failed' do
    m, o = create_sessions
    title = 'title'
    body = 'ハロー'
    code = 'puts hello'
    source_url = 'https://github.com/kotarou1192/fourecode'
    reward = 20_000_000
    post '/api/v1/posts', params: { token: { onetime: o.token }, value: { title: title, body: body, code: code, source_url: source_url, bestanswer_reward: reward } }
    assert response.status == 400
  end

  test 'post with empty body should be failed' do
    m, o = create_sessions
    title = 'title'
    body = '  '
    code = 'puts hello'
    source_url = 'https://github.com/kotarou1192/fourecode'
    reward = 200
    post '/api/v1/posts', params: { token: { onetime: o.token }, value: { title: title, body: body, code: code, source_url: source_url, bestanswer_reward: reward } }
    assert response.status == 400
  end

  test 'post with empty code should be failed' do
    m, o = create_sessions
    title = 'title'
    body = 'ハロー'
    code = '  '
    source_url = 'https://github.com/kotarou1192/fourecode'
    reward = 200
    post '/api/v1/posts', params: { token: { onetime: o.token }, value: { title: title, body: body, code: code, source_url: source_url, bestanswer_reward: reward } }
    assert response.status == 400
  end

  test 'post with invalid reward should be failed' do
    m, o = create_sessions
    title = 'title'
    body = 'ハロー'
    code = 'puts hello'
    source_url = 'https://github.com/kotarou1192/fourecode'
    reward = 'money'
    post '/api/v1/posts', params: { token: { onetime: o.token }, value: { title: title, body: body, code: code, source_url: source_url, bestanswer_reward: reward } }
    assert response.status == 400
  end

  test 'post with blank title should be failed' do
    m, o = create_sessions
    title = '  '
    body = 'ハロー'
    code = 'puts hello'
    source_url = 'https://github.com/kotarou1192/fourecode'
    reward = ''
    post '/api/v1/posts', params: { token: { onetime: o.token }, value: { title: title, body: body, code: code, source_url: source_url, bestanswer_reward: reward } }
    assert response.status == 400
  end
end
