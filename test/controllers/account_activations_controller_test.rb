require 'test_helper'

class AccountActivationsControllerTest < ActionDispatch::IntegrationTest
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
  end

  test 'invalid activate link responses status 400' do
    put '/api/v1/account_activations', params: { hoge: { token: 'hogefuga', email: 'hogefuga@fuga.fuga' } }
    body = JSON.parse(response.body)
    assert response.status == 400 && body['errors'][0]['key'] == 'link'
  end

  test 'the user should be activated' do
    put '/api/v1/account_activations', params: { value: { token: @user.activation_token, email: @email } }

    assert response.status == 200
  end
end
