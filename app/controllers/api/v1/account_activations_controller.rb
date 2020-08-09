# frozen_string_literal: true

class Api::V1::AccountActivationsController < ApplicationController
  def update
    user = User.find_by(email: params[:value][:email])

    if user && !user.activated? && user.authenticated?(:activation, params[:value][:token])
      user.activate
      render json: { status: 'SUCCESS', body: { message: 'activated' } }
    else
      render json: { status: 'ERROR', message: 'invalid activation link' }
    end
  end
end
