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
  end

  test 'user should create' do
    user_name = 'hogefuga'
    user_email = 'hogefuga@hoge.com'
    post '/api/v1/users', params: { value: { name: user_name, nickname: 'hogefuga', email: user_email, password: 'hogefuga' } }
    user = User.find_by(email: user_email)
    assert user.name == user_name
  end
end
