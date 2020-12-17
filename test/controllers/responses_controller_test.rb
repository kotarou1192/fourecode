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
    @session = create_sessions
  end

  def get_body
    @body = JSON.parse(response.body)
  end

  test 'should be created' do
    session = create_sessions
    text = 'awesome review'
    post "/api/v1/posts/#{@post.id}/reviews/#{@review.id}", params: { value: { body: text } }, headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    get_body
    assert @body['status'] == 'SUCCESS'
  end

  test 'closed post should reject to post response' do
    @post.close

    session = create_sessions
    text = 'awesome review'
    post "/api/v1/posts/#{@post.id}/reviews/#{@review.id}", params: { value: { body: text } }, headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    get_body
    assert @body['status'] == 'FAILED'
    assert @body['errors'].first['key'] == 'closed'
  end

  test 'can not response to response' do
    response = @review.reply(user: @user, body: 'body')

    session = create_sessions
    text = 'awesome review'
    post "/api/v1/posts/#{@post.id}/reviews/#{response.id}", params: { value: { body: text } }, headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    get_body
    assert @body['status'] == 'FAILED'
    assert @body['errors'].first['key'] == 'response'
  end

  # reviewにレスポンスをしたときユーザーが消せなかったため、そのテスト
  test 'user should be deleted' do
    session = create_sessions
    text = 'awesome review'
    post "/api/v1/posts/#{@post.id}/reviews/#{@review.id}", params: { value: { body: text } }, headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    assert response.status == 200
    delete "/api/v1/users/#{@user.name}", headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    assert response.status == 200
    get "/api/v1/users/#{@user.name}"
    assert response.status == 404
  end
end
