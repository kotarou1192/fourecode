require 'test_helper'

class UsersSearchesControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  # search users test
  def setup
    @email = 'hoge@email.com'
    @user = User.new(name: 'hoge',
                     nickname: 'hogechan',
                     email: @email,
                     password: 'hogefuga')
    @user.save
    @user.activate

    @email2 = 'hogehoge@email.com'
    @not_activated_user = User.new(name: 'not',
                                   nickname: 'not',
                                   email: @email2,
                                   password: 'hogefuga')
    @not_activated_user.save
  end

  test 'too many keywords should be rejected when search users' do
    get '/api/v1/search/users', params: { keyword: 't e s t k e y w o r d s i s t o o m a n y' }
    body = JSON.parse(response.body)

    body['errors'].each do |error|
      assert error['key'] == 'keyword'
    end
  end

  test 'users should be found' do
    get '/api/v1/search/users', params: { keyword: 'hoge' }
    body = JSON.parse(response.body)

    body['body']['results'].each do |result|
      assert result['name'] == @user.name
    end
  end

  test 'not activated user should not be found' do
    get '/api/v1/search/users', params: { keyword: 'not' }
    body = JSON.parse(response.body)

    assert body['body']['results'].empty?
  end
end
