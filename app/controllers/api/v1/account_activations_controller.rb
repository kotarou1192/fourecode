# frozen_string_literal: true

class Api::V1::AccountActivationsController < ApplicationController
  include ErrorMessageHelper

  def update
    user = User.find_by(email: params[:value][:email])

    if user && !user.activated? && user.authenticated?(:activation, params[:value][:token])
      user.activate
      render json: { status: 'SUCCESS', body: { message: 'activated' } }
    else
      message = 'invalid activation link'
      render status: 400, json: { status: 'ERROR', message: message }
        .merge(error_messages(key: 'link', message: message))
    end
  end
end
