require 'test_helper'

class ReviewCoinTransactionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  include Coin

  def setup
    @user = User.create(name: 'aaa', email: 'aaa@aaa.com', password: 'aaaaaa')
    @from = User.create(name: 'bbb', email: 'bbb@bbb.com', password: 'bbbbbb')
    @post = @user.posts.create(title: 'title', body: 'body', code: 'code')
    @review = Review.generate_record(body: 'body', user: @user, post: @post)
    @review.save
  end

  test 'should be falsy' do
    assert_not ReviewCoinTransaction.already_threw?(review_id: @review.id, user_id: @from.id)
  end

  test 'should be truthy' do
    assert Coin.throw(amount: 100, from: @from, review: @review)
    assert ReviewCoinTransaction.already_threw?(review_id: @review.id, user_id: @from.id)
  end

  test 'should be created' do
    assert ReviewCoinTransaction.create_record(review: @review, from: @from, amount: 100)
  end
end
