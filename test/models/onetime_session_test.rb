# frozen_string_literal: true

require 'test_helper'

class OnetimeSessionTest < ActiveSupport::TestCase
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
    @onetime_session = @user.onetime_session.create
  end

  test 'should be present' do
    assert @onetime_session
  end

  test 'the token should be able to refer' do
    assert @onetime_session.token
  end

  test 'the session should be found' do
    session = OnetimeSession.find_by(token_digest: OnetimeSession.digest(@onetime_session.token))
    assert session
  end

  test 'the user should be found by the session' do
    session = OnetimeSession.find_by(token_digest: OnetimeSession.digest(@onetime_session.token))
    user = User.find_by(id: session.user_id)
    assert user.email == @email
  end

  test 'old session should not be available' do
    @onetime_session.update(created_at: 10.days.ago)

    assert_not @onetime_session.available?
  end

  test 'the sessions should be found by the user' do
    @user.onetime_session.create
    @onetime_session.update(created_at: 10.days.ago)
    sessions = OnetimeSession.order(:created_at).where(user_id: @user.id)
    assert sessions.size == 2 && !sessions[0].available?
  end
end
