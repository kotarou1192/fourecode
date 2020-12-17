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

  def get_body
    @body = JSON.parse(response.body)
  end

  test 'reviews and responses should be shown' do
    get "/api/v1/posts/#{@post.id}/reviews", params: {}
    get_body
    assert @body['body']['reviews'].first['id'] == @review.id
    assert @body['body']['reviews'].first['responses'].first['id'] == @res.id
    assert @body['body']['total_contents_count'] == 2
  end

  test 'should be created' do
    session = create_sessions
    text = 'awesome review'
    post "/api/v1/posts/#{@post.id}/reviews", params: { value: { body: text } }, headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    get_body
    assert @body['status'] == 'SUCCESS'
  end

  test 'closed post should reject response' do
    @post.close

    session = create_sessions
    text = 'awesome review'
    post "/api/v1/posts/#{@post.id}/reviews", params: { value: { body: text } }, headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    get_body
    assert @body['status'] == 'FAILED'
    assert @body['errors'].first['key'] == 'closed'
  end

  test 'reviews should be shown by username' do
    get "/api/v1/users/#{@user.name}/reviews"
    get_body
    assert @body['status'] == 'SUCCESS'
    assert @body['body']['total_contents_count'] == 2
  end

  test 'deleted posts review should not be found' do
    session = create_sessions
    delete "/api/v1/users/#{@user.name}", headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    assert response.status == 200
    get "/api/v1/users/#{@user.name}"
    assert response.status == 404
  end
end
