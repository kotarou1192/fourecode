# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
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

  test 'should be valid' do
    assert @user.valid?
  end

  test 'password should be present (nonblank)' do
    @user.password = ' ' * 6
    assert_not @user.valid?
  end

  test 'password should have a minimum length' do
    @user.password = 'a' * 5
    assert_not @user.valid?
  end

  test 'id should be present' do
    assert @user.id
  end

  test 'password_digest should be match digest' do
    assert @user.password_digest == User.digest(@user.password)
  end

  test 'should not be activated' do
    assert_not @user.activated?
  end

  test 'should be activated' do
    @user.activate
    assert @user.activated?
  end
end
