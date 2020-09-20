# frozen_string_literal: true

class Api::V1::PasswordResetsController < ApplicationController
  include ErrorMessageHelper
  include ResponseStatus
  include ResponseHelper

  # PUTで呼び出す
  # パラメーターの内容
  # {
  #   token: token
  #   value: {
  #     password: new_password
  #   }
  # }
  def update
    session = PasswordResetSession.find_by(token_digest: PasswordResetSession.digest(token))
    unless session
      message = 'invalid reset link'
      key = 'link'
      return error_response(key: key, message: message)
    end

    unless session.available?
      message = 'the link is too old'
      key = 'link'
      return error_response(key: key, message: message)
    end

    unless user_params[:password]
      message = 'password does not exit'
      key = 'password'
      return error_response(key: key, message: message)
    end

    user = session.user
    user.password = user_params[:password]
    user.create_password_digest
    if user.save
      session.destroy
      return render json: generate_response(SUCCESS, message: 'your password has been changed')
    end

    failed_to_create user
  end

  # POSTで呼び出す
  # パラメーターの内容
  # {
  #   value: {
  #     email: target_account's_email
  #   }
  # }
  def create
    user = User.find_by(email: user_params[:email])
    unless user
      message = 'the email address does not exist'
      key = 'email'
      return error_response(key: key, message: message)
    end
    unless user.activated?
      message = 'account is not activated'
      key = 'account'
      return error_response(key: key, message: message)
    end

    user.send_password_reset_email
    render json: generate_response(SUCCESS, message: 'password reset mail has been sent')
  end

  private

  def token
    params.permit(:token)[:token]
  end

  def user_params
    params.require(:value).permit(:email, :password)
  end
end
