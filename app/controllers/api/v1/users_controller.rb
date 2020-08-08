# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      include LoginHelper

      SUCCESS = 'SUCCESS'
      FAILED = 'FAILED'
      ERROR = 'ERROR'
      OLD_TOKEN = 'OLD_TOKEN'

      def create
        @user = User.new(user_params)
        unless @user.valid?
          return render json: generate_response(FAILED, messages: @user.errors.messages)
        end

        if @user.save
          # 何がしかのアクティベートをする
          render json: generate_response(SUCCESS, message: 'activation mail has been sent')
        else
          render json: generate_response(ERROR, messages: @user.errors.messages)
        end
      end

      def show
        if user_tokens[:onetime]
          onetime_session = login?(user_tokens[:onetime])
          if onetime_session && token_availavle?(user_tokens[:onetime])
            @session_user = User.find_by(id: onetime_session.user_id)
          elsif !token_availavle?(user_tokens[:onetime])
            return render json: generate_response(OLD_TOKEN, message: 'onetime token is unavailable')
          end
        end

        selected_user = User.find_by(name: user_name)
        unless selected_user
          return render json: generate_response(FAILED, message: 'invalid user name')
        end

        body = {
          name: selected_user.name,
          nickname: selected_user.nickname,
          explanation: nil,
          icon: nil,
          is_admin: selected_user.admin?,
          is_mypage: @session_user == selected_user
        }

        render json: generate_response(SUCCESS, body)
      end

      def update
        onetime_session = login?(user_tokens[:onetime])
        unless onetime_session
          return render json: generate_response(FAILED, message: 'you are not logged in')
        end

        unless token_availavle?(user_tokens[:onetime])
          return render json: generate_response(OLD_TOKEN, message: 'onetime token is too old')
        end

        selected_user = User.find_by(name: user_name)
        unless selected_user
          return render json: generate_response(FAILED, message: 'invalid user name')
        end

        session_user = onetime_session.user

        unless session_user.admin? || session_user == selected_user
          return render json: generate_response(ERROR, message: 'you are not admin')
        end

        if update_selected_user(selected_user)
          render json: generate_response(SUCCESS, message: 'user parameters are updated successfully')
        else
          render json: generate_response(FAILED, messages: selected_user.errors.messages)
        end
      end

      def destroy
        onetime_session = login?(user_tokens[:onetime])
        unless onetime_session
          return render json: generate_response(FAILED, message: 'you are not logged in')
        end

        unless token_availavle?(user_tokens[:onetime])
          return render json: generate_response(OLD_TOKEN, message: 'onetime token is too old')
        end

        session_user = onetime_session.user
        selected_user = User.find_by(name: user_name)
        unless selected_user
          return render json: generate_response(FAILED, message: 'invalid user name')
        end

        unless session_user.admin? || session_user == selected_user
          return render json: generate_response(ERROR, message: 'you are not admin')
        end

        if selected_user.destroy
          render json: generate_response(SUCCESS, message: 'user is deleted successfully')
        else
          render json: generate_response(FAILED, messages: selected_user.errors.messages)
        end
      end

      private

      def update_selected_user(user)
        user.transaction do
          user.update!(name: user_params[:name]) if user_params[:name]
          if user_params[:nickname]
            user.update!(nickname: user_params[:nickname])
          end
          user.update!(email: user_params[:email]) if user_params[:email]
          if user_params[:password]
            user.password = user_params[:password]
            user.update!(password_digest: User.digest(user.password))
          end
          return true
        end
      rescue ActiveRecord::RecordInvalid
        false
      end

      def user_name
        params.permit(:id)[:id]
      end

      def user_params
        params.require(:value).permit(:name, :nickname, :email, :password)
      end

      def user_tokens
        return {} if params[:token].nil?

        params.require(:token).permit(:onetime, :master)
      end

      def create_sessions
        ActiveRecord::Base.transaction do
          @master_session = @user.master_session.create!
          @onetime_session = @user.onetime_session.create!
        end
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
