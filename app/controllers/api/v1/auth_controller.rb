# frozen_string_literal: true

module Api
  module V1
    class AuthController < ApplicationController
      include ErrorMessageHelper
      include ResponseStatus

      # log-in
      def create
        return update if user_tokens[:master]

        if params[:value].nil? || user_params[:email].nil? || user_params[:password].nil?
          return error_response json: generate_response(FAILED, nil)
        end

        user = User.find_by(email: user_params[:email].downcase)
        unless user
          return render status: 400, json: generate_response(FAILED, nil)
        end

        unless user.activated?
          return render status: 400, json: generate_response(FAILED, nil)
        end

        if user.authenticated?(:password, user_params[:password])
          generate_access_token(user)
          return render json: generate_response(SUCCESS, token: { master: @master_session.token, onetime: @onetime_session.token })
        end

        render status: 400, json: generate_response(FAILED, nil)
      end

      def index
        if user_token_from_get_params.nil?
          message = 'property onetime of token is empty'
          return render status: 400, json: generate_response(FAILED, message: message)
                                             .merge(error_messages(key: 'token', message: message))
        end

        onetime_session = OnetimeSession.find_by(token_digest: OnetimeSession.digest(user_token_from_get_params))
        unless onetime_session
          message = 'you are not logged in'
          return render status: 400, json: generate_response(FAILED, message: message)
                                             .merge(error_messages(key: 'login', message: message))
        end

        user = User.find_by(id: onetime_session.user_id)
        unless onetime_session.available?
          onetime_session.destroy!
          message = 'onetime token is too old'
          return render status: 400, json: generate_response(OLD_TOKEN, message: message)
                                             .merge(error_messages(key: 'token', message: message))
        end

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

      def update
        if user_tokens[:master].nil?
          message = 'property master of token is empty'
          return render status: 400, json: generate_response(FAILED, message: message)
                                             .merge(error_messages(key: 'token', message: message))
        end

        master_session = MasterSession.find_by(token_digest: MasterSession.digest(user_tokens[:master]))
        unless master_session
          message = 'you are not logged in'
          return render status: 400, json: generate_response(FAILED, message: message)
                                             .merge(error_messages(key: 'login', message: message))
        end

        user = User.find_by(id: master_session.user_id)
        unless master_session.available?
          master_session.destroy!
          message = 'master token is too old'
          return render status: 400, json: generate_response(OLD_TOKEN, message: message)
                                             .merge(error_messages(key: 'token', message: message))
        end

        MasterSession.destroy_old_sessions(user)
        onetime_session = master_session.onetime_session.new
        onetime_session.user = user
        onetime_session.save!
        render json: generate_response(SUCCESS, token: { onetime: onetime_session.token })
      end

      # log-out
      def destroy
        if user_token_from_get_params.nil?
          message = 'you are not logged in'
          return render status: 400, json: generate_response(FAILED, message: message)
                                             .merge(error_messages(key: 'login', message: message))
        end

        onetime_session = OnetimeSession.find_by(token_digest: OnetimeSession.digest(user_token_from_get_params))
        unless onetime_session
          message = 'you are not logged in'
          return render status: 400, json: generate_response(FAILED, message: message)
                                             .merge(error_messages(key: 'login', message: message))
        end

        unless onetime_session.available?
          onetime_session.destroy!
          message = 'onetime token is too old'
          return render status: 400, json: generate_response(OLD_TOKEN, message: message)
                                             .merge(error_messages(key: 'token', message: message))
        end

        user = User.find_by(id: onetime_session.user_id)
        MasterSession.destroy_sessions(user)
        render json: generate_response(SUCCESS, message: 'logout successful')
      end

      private

      def generate_access_token(user)
        ActiveRecord::Base.transaction do
          @master_session = user.master_session.create!
          @onetime_session = @master_session.onetime_session.new
          @onetime_session.user = user
          @onetime_session.save!
        end
      end

      def user_params
        params.require(:value).permit(:email, :password)
      end

      def user_tokens
        return {} if params[:token].nil?

        params.require(:token).permit(:master, :onetime)
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
