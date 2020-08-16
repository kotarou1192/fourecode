# frozen_string_literal: true

class Api::V1::PasswordResetsController < ApplicationController
  SUCCESS = 'SUCCESS'
  FAILED = 'FAILED'
  ERROR = 'ERROR'
  OLD_TOKEN = 'OLD_TOKEN'

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
      return render status: 400, json: generate_response(FAILED, message: 'invalid reset link')
    end

    unless session.available?
      return render status: 400, json: generate_response(FAILED, message: 'the link is too old')
    end

    unless user_params[:password]
      return render status: 400, json: generate_response(FAILED, message: 'password does not exit')
    end

    user = session.user
    user.password = user_params[:password]
    user.create_password_digest
    if user.save
      session.destroy
      return render json: generate_response(SUCCESS, message: 'your password has been changed')
    end

    render status: 400, json: generate_response(FAILED, message: user.errors.messages)
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
      return render status: 400, json: generate_response(FAILED, message: 'the email address does not exist')
    end
    unless user.activated?
      return render status: 400, json: generate_response(FAILED, message: 'account is not activated')
    end

    user.send_password_reset_email
    render json: generate_response(SUCCESS, message: 'passowrd reset mail has been sent')
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
