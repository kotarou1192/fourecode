# frozen_string_literal: true

class Api::V1::PasswordResetsController < ApplicationController
  include ErrorMessageHelper
  include ResponseStatus

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
      return render status: 400, json: generate_response(FAILED, message: message)
                                         .merge(error_messages(key: 'invalid_link', message: message))
    end

    unless session.available?
      message = 'the link is too old'
      return render status: 400, json: generate_response(FAILED, message: message)
                                         .merge(error_messages(key: 'old_link', message: message))
    end

    unless user_params[:password]
      message = 'password does not exit'
      return render status: 400, json: generate_response(FAILED, message: message)
                                         .merge(error_messages(key: 'password', message: message))
    end

    user = session.user
    user.password = user_params[:password]
    user.create_password_digest
    if user.save
      session.destroy
      return render json: generate_response(SUCCESS, message: 'your password has been changed')
    end

    error_messages = generate_error_messages_from_errors(user.errors.messages)
    render status: 400, json: generate_response(FAILED, nil)
                                .merge(error_messages(error_messages: error_messages))
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
      return render status: 400, json: generate_response(FAILED, message: message)
                                         .merge(error_messages(key: 'email', message: message))
    end
    unless user.activated?
      message = 'account is not activated'
      return render status: 400, json: generate_response(FAILED, message: message)
                                         .merge(error_messages(key: 'account', message: message))
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

  def generate_response(status, body)
    {
      status: status,
      body: body
    }
  end
end
