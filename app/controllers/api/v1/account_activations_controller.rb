# frozen_string_literal: true

class Api::V1::AccountActivationsController < ApplicationController
  include ErrorMessageHelper
  include ResponseHelper
  include ResponseStatus
  include ErrorKeys

  def update
    user = User.find_by(email: user_params[:email])

    if user && !user.activated? && user.authenticated?(:activation, user_params[:token])
      user.activate
      render json: generate_response(SUCCESS, message: 'activated')
    else
      message = 'invalid activation link'
      key = ErrorKeys::LINK
      error_response(key: key, message: message)
    end
  end

  private

  def user_params
    return {} unless params[:value]

    params.require(:value).permit(:email, :token)
  end
end
