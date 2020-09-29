require 'test_helper'

class CorsTest < ActionDispatch::IntegrationTest
  test 'cors test' do
    get '/api/v1/users/one', headers: { origin: 'http://example.com' }
    assert response.header['Access-Control-Allow-Origin'] == '*'
  end
end
