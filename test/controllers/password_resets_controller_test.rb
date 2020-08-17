# frozen_string_literal: true

require 'test_helper'

class PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    @email = 'hogehoge@email.com'
    @user = User.new(name: 'hoge',
                     nickname: 'hogechan',
                     email: @email,
                     password: 'hogefuga')
    @user.save
    @user.activate
    @invalid_user = User.new(name: 'maja',
                             nickname: 'nama',
                             email: 'nama@nama.com',
                             password: 'hogefuga')
    @invalid_user.save
  end

  # forgot password

  test 'a email should be sent' do
    post '/api/v1/password_resets', params: { value: { email: @user.email } }
    body = JSON.parse(response.body)
    assert body['status'] == 'SUCCESS'
  end

  test 'invalid email should be rejected' do
    post '/api/v1/password_resets', params: { value: { email: 'funuke' } }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'email'
  end

  test 'a account that is not activated should be rejected' do
    post '/api/v1/password_resets', params: { value: { email: @invalid_user.email } }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'account'
  end

  # change password

  test 'password should be changed' do
    session = @user.create_password_reset_session
    token = session.token
    new_password = 'mitsuhiko'

    put '/api/v1/password_resets', params: { token: token, value: { password: new_password } }

    user = User.find_by(email: @email)
    assert user.authenticated?(:password, new_password)
  end

  test 'old reset token should be rejected' do
    session = @user.create_password_reset_session
    session.update(created_at: 100.days.ago)
    token = session.token
    new_password = 'mitsuhiko'

    put '/api/v1/password_resets', params: { token: token, value: { password: new_password } }

    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'old_link'
  end

  test 'empty password should be rejected' do
    session = @user.create_password_reset_session
    token = session.token

    put '/api/v1/password_resets', params: { token: token, value: { password: nil } }

    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'password'
  end

  test 'invalid reset token should be rejected' do
    new_password = 'mitsuhiko'

    put '/api/v1/password_resets', params: { token: 'hoge_token', value: { password: new_password } }

    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'invalid_link'
  end

  test 'short password should be rejected' do
    session = @user.create_password_reset_session
    token = session.token
    new_password = 'mits'

    put '/api/v1/password_resets', params: { token: token, value: { password: new_password } }

    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'password'
  end
end
