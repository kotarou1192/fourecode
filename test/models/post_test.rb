require 'test_helper'

class PostTest < ActiveSupport::TestCase
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

    @answer_email = 'answer@email.com'
    @answer_user = User.new(name: 'answer',
                            nickname: 'answer_nickname',
                            email: @answer_email,
                            password: 'hogefuga')
    @answer_user.save
    @answer_user.activate

    @post = @user.posts.new
    @post.source_url = "http://hogehoge.com/hoge"
    @post.body = 'この命名、きれい？'
    @post.code = 'puts hello'
    @post.title = 'meimei'
    @post.bestanswer_reward = 100
  end

  test 'should be valid' do
    assert @post.save
  end

  test 'default state should be open' do
    assert @post.state == 'open'
  end

  test 'post should be resolved' do
    @post.close
    assert @post.closed?
  end

  test 'post state should be changed' do
    @post.change_state 'closed'
    assert @post.state == 'closed'
  end

  test 'body should be present' do
    @post.body = ' ' * 6
    assert_not @post.valid?
  end

  test 'invalid status should be rejected' do
    begin
      @post.change_state 'hoge'
    rescue => error
      assert error.is_a? ArgumentError
    end
  end

  test 'asked user should be set' do
    @post.save
    @post.ask_to([@answer_user])
    assert AskedUser.find_by(user_id: @answer_user.id)
  end
end
