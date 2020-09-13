require 'test_helper'
require 'rake'

class ShowReviewTest < ActiveSupport::TestCase
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

  test 'should be got' do
    response = @review.reply(body: 'reply', user: @user)
    reviews = ShowReview.show(@post.id)
    review = reviews[0]
    responses = review[:responses]
    reply = responses[0]
    assert reply[:body] == response.body
  end
end
