# frozen_string_literal: true

class UserMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject
  #
  def account_activation(user)
    @user = user
    domain = 'localhost:3000'
    protocol = 'http'
    @user.activation_token
    body = {
      token: @user.activation_token,
      email: @user.email
    }
    @url = url_with_params("#{protocol}://#{domain}/account/activate", body)
    mail to: @user.email
  end

  def url_with_params(url, params = {})
    uri = URI.parse(url)
    uri.query = URI.encode_www_form(params.to_a)
    uri.to_s
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset
    @greeting = 'Hi'

    mail to: 'to@example.org'
  end
end
