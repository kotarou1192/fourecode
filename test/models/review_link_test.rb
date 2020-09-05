require 'test_helper'

class ReviewLinkTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @email = 'hoge@email.com'
    @to = User.new(name: 'hoge',
                   nickname: 'hogechan',
                   email: @email,
                   password: 'hogefuga')
    @to.save

    @email2 = 'hogehoge@email.com'
    @from = User.new(name: 'fuga',
                     nickname: 'fuga',
                     email: @email2,
                     password: 'hogefuga')
    @from.save

    @post = @from.posts.new
    @post.source_url = 'http://hogehoge.com/hoge'
    @post.body = 'この命名、きれい？'
    @post.code = 'puts hello'
    @post.title = 'meimei'
    @post.bestanswer_reward = 100

    @post.save

    @review = Review.generate_record(body: 'hoge', user: @to, post: @post)
    @review.save
  end

  test 'should be valid' do
    response = @review.reply(body: 'reply', user: @from)
    assert ReviewLink.response?(response)
  end
end
