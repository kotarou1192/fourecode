require 'test_helper'

class ResponsesControllerTest < ActionDispatch::IntegrationTest
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

  test 'should be created' do
    m, o = create_sessions
    text = 'awesome review'
    post "/api/v1/posts/#{@post.id}/reviews/#{@review.id}", params: { value: { body: text }, token: { onetime: o.token } }
    get_body
    assert @body['status'] == 'SUCCESS'
  end

  test 'closed post should reject to post response' do
    @post.close

    m, o = create_sessions
    text = 'awesome review'
    post "/api/v1/posts/#{@post.id}/reviews/#{@review.id}", params: { value: { body: text }, token: { onetime: o.token } }
    get_body
    assert @body['status'] == 'FAILED'
    assert @body['errors'].first['key'] == 'closed'
  end

  test 'can not response to response' do
    response = @review.reply(user: @user, body: 'body')

    m, o = create_sessions
    text = 'awesome review'
    post "/api/v1/posts/#{@post.id}/reviews/#{response.id}", params: { value: { body: text }, token: { onetime: o.token } }
    get_body
    assert @body['status'] == 'FAILED'
    assert @body['errors'].first['key'] == 'response'
  end
end
