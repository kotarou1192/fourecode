# frozen_string_literal: true

require 'test_helper'

class MasterSessionTest < ActiveSupport::TestCase
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
    @master_session = @user.master_session.create
  end

  test 'should be present' do
    assert @master_session
  end

  test 'the token should be able to refer' do
    assert @master_session.token
  end

  test 'the session should be found' do
    session = MasterSession.find_by(token_digest: MasterSession.digest(@master_session.token))
    assert session
  end

  test 'the user found by the session' do
    session = MasterSession.find_by(token_digest: MasterSession.digest(@master_session.token))
    user = User.find_by(id: session.user_id)
    assert user.email == @email
  end
end
