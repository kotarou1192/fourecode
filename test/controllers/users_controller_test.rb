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

  def create_sessions
    master_session = @user.master_session.create
    onetime_session = master_session.onetime_session.new
    onetime_session.user = @user
    onetime_session.save
    [master_session, onetime_session]
  end

  # create user test

  test 'user should create' do
    user_name = 'hogefuga'
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
    master, onetime = create_sessions
    onetime.update(created_at: 100.days.ago)
    get '/api/v1/users/hoge', params: { token: onetime.token }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'token'
  end

  test 'users should be found' do
    master, onetime = create_sessions
    get '/api/v1/users/hoge', params: { token: onetime.token }
    body = JSON.parse(response.body)
    assert response.status == 200 && body['body'].is_a?(Array)
  end

  # update user test

  test 'empty token should be rejected in update' do
    master, onetime = create_sessions
    put '/api/v1/users/hoge', params: { token: { onetime: nil }, value: { name: 'hogetaro' } }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'token'
  end

  test 'old token should be rejected in update' do
    master, onetime = create_sessions
    onetime.update(created_at: 100.days.ago)
    put '/api/v1/users/hoge', params: { token: { onetime: onetime.token }, value: { name: 'hogetaro' } }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'token'
  end

  test 'invalid token should be rejected in update' do
    master, onetime = create_sessions
    put '/api/v1/users/hoge', params: { token: { onetime: 'hoge' }, value: { name: 'hogetaro' } }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'login'
  end

  test 'invalid name should be rejected in update' do
    master, onetime = create_sessions
    put '/api/v1/users/papa', params: { token: { onetime: onetime.token }, value: { name: 'hogetaro' } }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'name'
  end

  test 'you are not admin' do
    master, onetime = create_sessions
    put '/api/v1/users/punipuni', params: { token: { onetime: onetime.token }, value: { name: 'hogetaro' } }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'admin'
  end

  test 'invalid user parameters should be rejected in update' do
    master, onetime = create_sessions
    put '/api/v1/users/hoge', params: { token: { onetime: onetime.token },
                                        value: { name: '  ', nickname: 'hogefuga', email: 'invalid', password: 'fu' } }
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
    master, onetime = create_sessions
    delete '/api/v1/users/hoge', params: { token: nil }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'token'
  end

  test 'invalid token should be rejected in delete' do
    master, onetime = create_sessions
    delete '/api/v1/users/hoge', params: { token: 'gohho' }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'login'
  end

  test 'old token should be rejected in delete' do
    master, onetime = create_sessions
    onetime.update(created_at: 100.days.ago)
    delete '/api/v1/users/hoge', params: { token: onetime.token }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'token'
  end

  test 'invalid user name should be rejected in delete' do
    master, onetime = create_sessions
    delete '/api/v1/users/piyopiyo', params: { token: onetime.token }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'name'
  end

  test 'you are not admin in delete' do
    master, onetime = create_sessions
    delete '/api/v1/users/punipuni', params: { token: onetime.token }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'admin'
  end

  test 'user should be deleted' do
    master, onetime = create_sessions
    delete '/api/v1/users/hoge', params: { token: onetime.token }
    assert response.status == 200
  end
end
