# frozen_string_literal: true

class Api::V1::AccountActivationsController < ApplicationController
  include ErrorMessageHelper

  def update
    user = User.find_by(email: user_params[:email])

    if user && !user.activated? && user.authenticated?(:activation, user_params[:token])
      user.activate
      render json: { status: 'SUCCESS', body: { message: 'activated' } }
    else
      message = 'invalid activation link'
      render status: 400, json: { status: 'ERROR', message: message }
                                  .merge(error_messages(key: 'link', message: message))
    end


  end

  private

  def user_params
    return {} unless params[:value]

    params.require(:value).permit(:email, :token)
  end
end
