# frozen_string_literal: true

module Api
  module V1
    class AuthController < ApplicationController
      include ErrorMessageHelper
      include ResponseStatus
      include ErrorKeys
      include LoginHelper

      # log-in
      def create
        return update if user_tokens[:master]

        if params[:value].nil? || user_params[:email].nil? || user_params[:password].nil?
          return error_response_base json: generate_response(FAILED, nil)
        end

        user = User.find_by(email: user_params[:email].downcase)
        unless user
          return render status: 400, json: generate_response(FAILED, nil)
        end

        unless user.activated?
          return render status: 400, json: generate_response(FAILED, nil)
        end

        if user.authenticated?(:password, user_params[:password])
          token = generate_token(user)
          return render json: generate_response(SUCCESS, token: token)
        end

        render status: 400, json: generate_response(FAILED, nil)
      end

      def index
        return unless authenticate

        user = @user

        MasterSession.destroy_old_sessions(user)
        body = {
          name: user.name,
          nickname: user.nickname,
          explanation: user.explanation,
          icon: user.icon.url,
          is_admin: user.admin?,
          is_mypage: true
        }
        render json: generate_response(SUCCESS, body)
      end

      # log-out
      def destroy
        return unless authenticate
        user = @user

        MasterSession.destroy_sessions(user)
        render json: generate_response(SUCCESS, message: 'logout successful')
      end

      private

      def generate_token(user)
        user.master_session.create!.token
      end

      def user_params
        params.require(:value).permit(:email, :password)
      end

      def user_tokens
        return {} if params[:token].nil?

        params.permit(:token)[:token]
      end

      def user_token_from_get_params
        return nil if params[:token].nil?
        return nil unless params[:token].is_a?(String)

        params.permit(:token)[:token]
      end

      def generate_response(status, body)
        {
          status: status,
          body: body
        }
      end
    end
  end
end
