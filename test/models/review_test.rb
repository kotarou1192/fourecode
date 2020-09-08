require 'test_helper'

class ReviewTest < ActiveSupport::TestCase
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

    @post = @user.posts.new
    @post.source_url = 'http://hogehoge.com/hoge'
    @post.body = 'この命名、きれい？'
    @post.code = 'puts hello'
    @post.title = 'meimei'
    @post.bestanswer_reward = 100

    @post.save

    @review = Review.generate_record(body: 'hoge', user: @user, post: @post)
    @review.save
  end

  test 'should be valid' do
    assert @review.valid?
  end

  test 'should be created' do
    assert @review.reply(body: 'hogehoge', user: @user)
  end

  test 'empty body should not be valid' do
    @review.body = ''
    assert_not @review.valid?
  end

  test 'blank body should not be valid' do
    @review.body = ' '
    assert_not @review.valid?
  end

  test 'too long body should not be valid' do
    @review.body = 'a' * (Review::BODY_MAX_CHARS + 1)
    assert_not @review.valid?
  end

  test 'can not reply response' do
    reply = @review.reply(body: 'hogehoge', user: @user)
    begin
      reply.reply(body: 'hogehoge', user: @user)
    rescue
      return assert true
    end
    assert false
  end
end
