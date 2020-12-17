# frozen_string_literal: true

require 'test_helper'

class AuthControllerTest < ActionDispatch::IntegrationTest
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

  # login test

  test 'user should be login' do
    post '/api/v1/auth', params: { value: { email: @user.email, password: @user.password } }
    assert MasterSession.find_by(user_id: @user.id)
  end

  test 'invalid user email should be rejected' do
    post '/api/v1/auth', params: { value: { email: 'aaa@hotate.com', password: 'hanage' } }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['status'] == 'FAILED'
  end

  test 'invalid password should be rejected' do
    post '/api/v1/auth', params: { value: { email: @user.email, password: 'hanage' } }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['status'] == 'FAILED'
  end

  test 'not activated user should be rejected' do
    email = 'hotate@email.com'
    user = User.new(name: 'hotate',
                    nickname: 'hogechan',
                    email: email,
                    password: 'hogefuga')
    user.save

    post '/api/v1/auth', params: { value: { email: user.email, password: user.password } }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['status'] == 'FAILED'
  end

  test 'deleted user can not log-in' do
    session = create_sessions
    delete "/api/v1/users/#{@user.name}", headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    assert response.status == 200

    post '/api/v1/auth', params: { value: { email: @user.email, password: @user.password } }
    assert_not MasterSession.find_by(user_id: @user.id)
  end

  # get user info test

  test 'the user data should be got' do
    session = create_sessions
    get '/api/v1/auth', headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    body = JSON.parse(response.body)
    assert response.status == 200 && body['status'] == 'SUCCESS'
  end

  test 'invalid token should be rejected(the onetime session is not found)' do
    session = create_sessions
    get '/api/v1/auth', headers: { HTTP_AUTHORIZATION: "Bearer aaa" }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'token'
  end

  test 'token which is empty should be rejected' do
    session = create_sessions
    get '/api/v1/auth', headers: { HTTP_AUTHORIZATION: "Bearer " }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'token'
  end

  test 'old token should be rejected' do
    session = create_sessions
    session.update(created_at: 100.days.ago)
    get '/api/v1/auth', headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'token'
  end

  # logout test

  test 'user should be logout' do
    post '/api/v1/auth', params: { value: { email: @user.email, password: @user.password } }

    body = JSON.parse(response.body)
    token = body['body']['token']
    delete '/api/v1/auth', headers: { HTTP_AUTHORIZATION: "Bearer #{token}" }
    assert_not MasterSession.find_by(user_id: @user.id)
  end

  test 'user can not be logged out with empty token' do
    session = create_sessions
    delete '/api/v1/auth', headers: { HTTP_AUTHORIZATION: "Bearer " }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'token'
  end

  test 'user can not be logged out with old token' do
    session = create_sessions
    session.update(created_at: 100.days.ago)
    delete '/api/v1/auth', headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'token'
  end

  test 'user can not be logged out with invalid token' do
    session = create_sessions
    delete '/api/v1/auth', headers: { HTTP_AUTHORIZATION: "Bearer aaa" }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'token'
  end

  test 'deleted user can not log-out' do
    session = create_sessions
    delete "/api/v1/users/#{@user.name}", headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    assert response.status == 200

    delete '/api/v1/auth'
    assert response.status == 400
  end
end
