require 'test_helper'

class CoinControllerTest < ActiveSupport::TestCase
  include Coin

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

  test 'should be thrown' do
    assert Coin.throw(amount: 100, from: @from, review: @review)
  end

  test 'can not throw coin to same review twice' do
    assert Coin.throw(amount: 100, from: @from, review: @review)
    assert_not Coin.throw(amount: 100, from: @from, review: @review)
  end

  test 'should be failed' do
    # 自分に投げる
    assert_not Coin.throw(amount: 100, from: @to, review: @review)
    # 限界以上に投げる
    assert_not Coin.throw(amount: Coin::MAX_TRANSACTION_AMOUNT + 1, from: @from, review: @review)
  end

  test 'user coins should not be negative' do
    6.times.each do
      review = Review.generate_record(body: 'hoge', user: @to, post: @post)
      review.save
      assert Coin.throw(amount: 500, from: @from, review: review)
    end
    assert_not Coin.throw(amount: 100, from: @from, review: @review)
  end

  test 'should be taken from the user' do
    assert Coin.take(amount: 100, user: @from)
    assert @from.coins == User::DEFAULT_COINS - 100
  end

  test 'can not take too many coins from the user' do
    assert_not Coin.take(amount: User::DEFAULT_COINS + 1, user: @from)
  end

  test 'can not take minus amount of coins from users' do
    assert_not Coin.take(amount: -100, user: @from)
  end

  test 'a gift for you' do
    assert Coin.add(user: @from, amount: 100)
  end

  test 'a invalid gift for you' do
    assert_not Coin.add(user: @from, amount: -100)
  end
end
