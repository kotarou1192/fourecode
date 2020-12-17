require 'test_helper'

class PostsSearchesControllerTest < ActionDispatch::IntegrationTest
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
  end

  # search posts test
  test 'should be found' do
    get '/api/v1/search/posts', params: { keyword: 't' }
    body = JSON.parse(response.body)

    body['body']['results'].each do |result|
      assert result['title'] == @post.title
    end
  end

  test 'too many keywords should be rejected' do
    get '/api/v1/search/posts', params: { keyword: 't e s t k e y w o r d s i s t o o m a n y' }
    body = JSON.parse(response.body)

    body['errors'].each do |error|
      assert error['key'] == 'keyword'
    end
  end

  test 'not accepting posts should not be found' do
    get '/api/v1/search/posts', params: { keyword: 'resolved' }
    body = JSON.parse(response.body)

    assert body['body']['results'].empty?
  end

  test 'posts count should be 10' do
    10.times do
      @user.posts.create(title: 'hoge', body: 'hoge', code: 'hoge', source_url: 'test')
    end

    get '/api/v1/search/posts', params: { keyword: 'hoge', author: @user.name }
    body = JSON.parse(response.body)

    assert body['body']['hit_total'] == 10
  end

  # other
  test 'deleted users post should not be found' do
    session = create_sessions
    delete "/api/v1/users/#{@user.name}", headers: { HTTP_AUTHORIZATION: "Bearer #{session.token}" }
    assert response.status == 200
    get '/api/v1/search/posts', params: { keyword: '_' } # '_' is wildcard
    body = JSON.parse(response.body)

    body['body']['results'].each do |result|
      assert_not result['author']['name'] == @user.name
    end
  end
end
