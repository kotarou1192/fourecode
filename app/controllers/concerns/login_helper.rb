# frozen_string_literal: true

module LoginHelper
  extend ActiveSupport::Concern
  include ActionController::HttpAuthentication::Token::ControllerMethods

  def token_available?(token)
    session = login?(token)
    return false unless session&.available?

    true
  end

  def login?(onetime_token)
    MasterSession.find_by(token_digest: MasterSession.digest(onetime_token))
  end

  def authenticate
    unless token_valid?
      authenticate_failed
      return
    end

    @user
  end

  def token_valid?
    authenticate_with_http_token do |token, _option|
      session = MasterSession.find_by(token_digest: MasterSession.digest(token))

      session = nil unless session && session.available?

      @user = session ? session.user : nil
    end
    @user != nil
  end
end
