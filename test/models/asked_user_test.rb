require 'test_helper'

class AskedUserTest < ActiveSupport::TestCase
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

    @requested_email = 'answer@email.com'
    @requested_user = User.new(name: 'answer',
                               nickname: 'answer_nickname',
                               email: @requested_email,
                               password: 'hogefuga')
    @requested_user.save
    @requested_user.activate

    @post = @user.posts.new
    @post.source_url = "http://hogehoge.com/hoge"
    @post.body = 'この命名、きれい？'
    @post.code = 'puts hello'
  end

  test 'should be valid' do
    asked_user = @post.asked_users.new
    asked_user.user = @requested_user
    assert asked_user.save
  end
end
