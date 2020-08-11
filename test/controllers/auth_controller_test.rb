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

  test 'user should be login' do
    post '/api/v1/auth', params: { value: { email: @user.email, password: @user.password } }
    assert MasterSession.find_by(user_id: @user.id) && OnetimeSession.find_by(user_id: @user.id)
  end

  test 'user should be logout' do
    post '/api/v1/auth', params: { value: { email: @user.email, password: @user.password } }

    body = JSON.parse(response.body)
    _master_token = body['body']['token']['master']
    onetime_token = body['body']['token']['onetime']
    delete '/api/v1/auth', params: { token: onetime_token }
    assert_not MasterSession.find_by(user_id: @user.id) && OnetimeSession.find_by(user_id: @user.id)
  end
end
