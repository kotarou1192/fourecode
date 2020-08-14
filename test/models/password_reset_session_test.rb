# frozen_string_literal: true

require 'test_helper'

class PasswordResetSessionTest < ActiveSupport::TestCase
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

  test 'should be created' do
    password_reset_session = @user.create_password_reset_session

    assert password_reset_session.token && password_reset_session.token_digest
  end

  test 'should be available' do
    password_reset_session = @user.create_password_reset_session

    assert password_reset_session.available?
  end

  test 'should not be available' do
    password_reset_session = @user.create_password_reset_session

    password_reset_session.update(created_at: 3.hours.ago)

    assert_not password_reset_session.available?
  end

  test 'should be found' do
    password_reset_session = @user.create_password_reset_session

    found_session = PasswordResetSession.find_by(user_id: @user.id)

    assert found_session.token_digest == PasswordResetSession.digest(password_reset_session.token)
  end

  test "user's session is olways solo" do
    password_reset_session_1 = @user.create_password_reset_session
    password_reset_session_2 = @user.create_password_reset_session
    password_reset_session_3 = @user.create_password_reset_session

    target = PasswordResetSession.find_by(user_id: @user.id)
    notfound = PasswordResetSession.find_by(id: password_reset_session_1.id)

    assert PasswordResetSession.where(user_id: @user.id).size == 1 &&
           target.id == password_reset_session_3.id && notfound.nil?
  end
end
