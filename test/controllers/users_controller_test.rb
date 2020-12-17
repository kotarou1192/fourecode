# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
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
    @email2 = 'hogehoge@hoge.com'
    @user2 = User.new(name: 'punipuni',
                      nickname: 'kir',
                      email: @email2,
                      password: 'hogefuga')
    @user2.save
    @user2.activate
  end

  # create user test

  test 'invalid name should be rejected' do
    user_name = 'hogefuga?pow!'
    user_email = 'hogefuga@hoge.com'
    post '/api/v1/users', params: { value: { name: user_name, nickname: 'hogefuga', email: user_email, password: 'hogefuga' } }
    user = User.find_by(email: user_email)
    assert_not user
    body = JSON.parse(response.body)
    body['errors'].each do |error|
      assert error['key'] == 'name'
    end
  end

  test 'user should create' do
    user_name = 'hoge-fuga001'
    user_email = 'hogefuga@hoge.com'
    post '/api/v1/users', params: { value: { name: user_name, nickname: 'hogefuga', email: user_email, password: 'hogefuga' } }
    user = User.find_by(email: user_email)
    assert user.name == user_name
  end

  test 'invalid user parameters should be rejected' do
    user_name = '  '
    user_email = 'hihi'

    post '/api/v1/users', params: { value: { name: user_name, nickname: 'hogefuga', email: user_email, password: 'fu' } }
    body = JSON.parse(response.body)


    is_name_failed = body['errors'].any? do |error|
      error['key'] == 'name'
    end
    is_email_failed = body['errors'].any? do |error|
      error['key'] == 'email'
    end
    is_password_failed = body['errors'].any? do |error|
      error['key'] == 'password'
    end

    assert is_name_failed && is_email_failed && is_password_failed
  end

  # get user test

  test 'old token should be rejected' do
    session = create_sessions
    session.update(created_at: 100.days.ago)
    get '/api/v1/users/hoge', headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    body = JSON.parse(response.body)
    assert response.status == 200
  end

  test 'users should be found' do
    session = create_sessions
    get '/api/v1/users/hoge', headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    body = JSON.parse(response.body)
    assert response.status == 200
  end

  # update user test

  test 'empty token should be rejected in update' do
    session = create_sessions
    put '/api/v1/users/hoge', params: { value: { name: 'hogetaro' } }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'token'
  end

  test 'old token should be rejected in update' do
    session = create_sessions
    session.update(created_at: 100.days.ago)
    put '/api/v1/users/hoge', params: { value: { name: 'hogetaro' } }, headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'token'
  end

  test 'invalid token should be rejected in update' do
    session = create_sessions
    put '/api/v1/users/hoge', params: { value: { name: 'hogetaro' } }, headers: { HTTP_AUTHORIZATION: "Bearer hoge" }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'token'
  end

  test 'invalid name should be rejected in update' do
    session = create_sessions
    put '/api/v1/users/papa', params: { value: { name: 'hogetaro' } }, headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'name'
  end

  test 'you are not admin' do
    session = create_sessions
    put '/api/v1/users/punipuni', params: { value: { name: 'hogetaro' } }, headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'admin'
  end

  test 'invalid user parameters should be rejected in update' do
    session = create_sessions
    put '/api/v1/users/hoge', params: {
      value: { name: '  ', nickname: 'hogefuga', email: 'invalid', password: 'fu' } }, headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    body = JSON.parse(response.body)

    is_name_failed = body['errors'].any? do |error|
      error['key'] == 'name'
    end
    is_email_failed = body['errors'].any? do |error|
      error['key'] == 'email'
    end
    is_password_failed = body['errors'].any? do |error|
      error['key'] == 'password'
    end

    assert is_name_failed
  end

  # delete user test

  test 'empty token should be rejected in delete' do
    session = create_sessions
    delete '/api/v1/users/hoge'
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'token'
  end

  test 'invalid token should be rejected in delete' do
    session = create_sessions
    delete '/api/v1/users/hoge', headers: { HTTP_AUTHORIZATION: "Bearer #{session.token + 'aa'}" }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'token'
  end

  test 'old token should be rejected in delete' do
    session = create_sessions
    session.update(created_at: 100.days.ago)
    delete '/api/v1/users/hoge', headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'token'
  end

  test 'invalid user name should be rejected in delete' do
    session = create_sessions
    delete '/api/v1/users/piyopiyo', headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'name'
  end

  test 'you are not admin in delete' do
    session = create_sessions
    delete '/api/v1/users/punipuni', headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'admin'
  end

  test 'user should be deleted' do
    session = create_sessions
    delete '/api/v1/users/hoge', headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    assert response.status == 200
  end

  test 'deleted user should not be found' do
    session = create_sessions
    delete "/api/v1/users/#{@user.name}", headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    assert response.status == 200
    get "/api/v1/users/#{@user.name}"
    assert response.status == 404
  end
end
