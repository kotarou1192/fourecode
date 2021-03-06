# frozen_string_literal: true

class UserMailer < ApplicationMailer
  PROTOCOL = 'https'
  DOMAIN = '4ecode.com'
  SERVER_TYPE = ENV['SERVER_TYPE']
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject
  #
  def account_activation(user)
    @user = user
    @user.activation_token
    body = {
      token: @user.activation_token,
      email: @user.email
    }
    @url = url_with_params("#{PROTOCOL}://#{choose_subdomain}#{DOMAIN}/account/activate", body)
    mail to: @user.email
  end

  def url_with_params(url, params = {})
    uri = URI.parse(url)
    uri.query = URI.encode_www_form(params.to_a)
    uri.to_s
  end

  # return subdomain if SERVER_TYPE is 'feature' of 'development'
  def choose_subdomain
    if SERVER_TYPE == 'feature'
      return 'feature.'
    elsif SERVER_TYPE == 'development'
      return 'dev.'
    end
    ''
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user)
    @user = user
    password_reset_session = user.create_password_reset_session
    body = {
      token: password_reset_session.token
    }
    @url = url_with_params("#{PROTOCOL}://#{DOMAIN}/password/edit", body)
    mail to: @user.email
  end
end
