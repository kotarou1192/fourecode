# frozen_string_literal: true

module Api
  module V1
    class AuthController < ApplicationController
      SUCCESS = 'SUCCESS'
      FAILED = 'FAILED'
      ERROR = 'ERROR'
      OLD_TOKEN = 'OLD_TOKEN'
      # log-in
      def create
        return update if user_tokens[:master]

        user = User.find_by(email: user_params[:email].downcase)
        unless user
          return render json: generate_response(FAILED, message: 'invalid email address')
        end

        unless user.activated?
          return render json: generate_response(FAILED, message: 'account is not activated')
        end

        if user&.authenticated?(:password, user_params[:password])
          generate_access_token(user)
          return render json: generate_response(SUCCESS, token: { master: @master_session.token, onetime: @onetime_session.token })
        end

        render json: generate_response(FAILED, message: 'invalid password')
      end

      def update
        master_session = MasterSession.find_by(token_digest: MasterSession.digest(user_tokens[:master]))
        unless master_session
          return render json: generate_response(FAILED, message: 'you are not logged in')
        end

        user = User.find_by(id: master_session.user_id)
        unless master_session.available?
          master_session.destroy!
          return render json: generate_response(OLD_TOKEN, message: 'master token is too old.')
        end

        destroy_old_onetime_sessions(user)
        onetime_session = master_session.onetime_session.new
        onetime_session.user = user
        onetime_session.save!
        render json: generate_response(SUCCESS, token: { onetime: onetime_session.token })
      end

      # log-out
      def destroy
        if user_tokens[:onetime].nil?
          return render json: generate_response(FAILED, message: 'you are not logged in')
        end

        onetime_session = OnetimeSession.find_by(token_digest: OnetimeSession.digest(user_tokens[:onetime]))
        unless onetime_session
          return render json: generate_response(FAILED, message: 'you are not logged in')
        end

        unless onetime_session.available?
          onetime_session.destroy!
          return render json: generate_response(OLD_TOKEN, message: 'onetime token is too old')
        end

        user = User.find_by(id: onetime_session.user_id)
        destroy_sessions(user)
        render json: generate_response(SUCCESS, message: 'logout successful')
      end

      private

      def destroy_old_onetime_sessions(user)
        onetime_sessions = OnetimeSession.where(user_id: user.id)
        ActiveRecord::Base.transaction do
          onetime_sessions.each do |session|
            session.destroy! unless session.available?
          end
        end
      end

      def generate_access_token(user)
        ActiveRecord::Base.transaction do
          @master_session = user.master_session.create!
          @onetime_session = @master_session.onetime_session.new
          @onetime_session.user = user
          @onetime_session.save!
        end
      end

      def destroy_sessions(user)
        master_sessions = MasterSession.where(user_id: user.id)
        ActiveRecord::Base.transaction do
          master_sessions.each(&:destroy!)
        end
      end

      def user_params
        params.require(:value).permit(:email, :password)
      end

      def user_tokens
        return {} if params[:token].nil?

        params.require(:token).permit(:master, :onetime)
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
