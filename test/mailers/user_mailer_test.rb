# frozen_string_literal: true

require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
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

  test 'account_activation' do
    mail = UserMailer.account_activation(@user)
    assert_equal 'Account activation', mail.subject
    assert_equal [@email], mail.to
    assert_equal ['from@example.com'], mail.from
    # assert_match "Hi", mail.body.encoded
  end

  test 'password_reset' do
    mail = UserMailer.password_reset
    assert_equal 'Password reset', mail.subject
    assert_equal ['to@example.org'], mail.to
    assert_equal ['from@example.com'], mail.from
    # assert_match "Hi", mail.body.encoded
  end
end
