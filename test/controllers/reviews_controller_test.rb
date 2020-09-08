require 'test_helper'

class ReviewsControllerTest < ActionDispatch::IntegrationTest
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

    @post = @user.posts.create(title: 'test', body: 'test', code: 'test', source_url: 'test')
    @review = Review.generate_record(body: 'review', user: @user, post: @post)
    @review.save
    @res = @review.reply(body: 'reply', user: @user)
  end

  def create_sessions
    master_session = @user.master_session.create
    onetime_session = master_session.onetime_session.new
    onetime_session.user = @user
    onetime_session.save
    [master_session, onetime_session]
  end

  def get_body
    @body = JSON.parse(response.body)
  end

  test 'reviews and responses should be shown' do
    get "/api/v1/posts/#{@post.id}/reviews", params: {}
    get_body
    assert @body['body'].first['id'] == @review.id
    assert @body['body'].first['responses'].first['id'] == @res.id
  end

  test 'should be created' do
    m, o = create_sessions
    text = 'awesome review'
    post "/api/v1/posts/#{@post.id}/reviews", params: { value: { body: text }, token: { onetime: o.token } }
    get_body
    assert @body['status'] == 'SUCCESS'
  end

  test 'closed post should reject response' do
    @post.close

    m, o = create_sessions
    text = 'awesome review'
    post "/api/v1/posts/#{@post.id}/reviews", params: { value: { body: text }, token: { onetime: o.token } }
    get_body
    assert @body['status'] == 'FAILED'
    assert @body['errors'].first['key'] == 'closed'
  end
end