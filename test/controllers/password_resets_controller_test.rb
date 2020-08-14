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
  end

  test 'a email should be sent' do
    post '/api/v1/password_resets', params: { value: { email: @user.email } }
    body = JSON.parse(response.body)
    assert body['status'] == 'SUCCESS'
  end

  test 'password should be changed' do
    session = @user.create_password_reset_session
    token = session.token
    new_password = 'mitsuhiko'

    put '/api/v1/password_resets', params: { token: token, value: { password: new_password } }

    user = User.find_by(email: @email)
    assert user.authenticated?(:password, new_password)
  end
end
