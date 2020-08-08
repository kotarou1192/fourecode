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
    @onetime_session = @master_session.onetime_session.new
    @onetime_session.user = @user
    @onetime_session.save!
  end

  test 'should be present' do
    assert @master_session && @onetime_session
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

  test 'old session should not be available' do
    @master_session.update(created_at: 100.days.ago)

    assert_not @master_session.available?
  end

  test 'onetime session must not exist if master session deleted' do
    @master_session.destroy!

    onetime_session = OnetimeSession.find_by(user_id: @user.id)

    assert_not onetime_session
  end
end
