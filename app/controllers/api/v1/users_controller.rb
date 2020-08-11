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
          @user.send_activation_email
          render json: generate_response(SUCCESS, message: 'activation mail has been sent')
        else
          render json: generate_response(ERROR, messages: @user.errors.messages)
        end
      end

      def show
        if user_token_from_get_params
          onetime_session = login?(user_token_from_get_params)
          if onetime_session && token_availavle?(user_token_from_get_params)
            @session_user = User.find_by(id: onetime_session.user_id)
          elsif !token_availavle?(user_token_from_get_params)
            return render json: generate_response(OLD_TOKEN, message: 'onetime token is unavailable')
          end
        end

        selected_users = User.where(['name LIKE ?', "#{user_name}%"]).limit(100)
        if user_name.nil?
          return render json: generate_response(FAILED, message: 'invalid user name')
        end

        body = selected_users.map do |selected_user|
          next unless selected_user.activated?

          {
            name: selected_user.name,
            nickname: selected_user.nickname,
            explanation: selected_user.explanation,
            icon: selected_user.icon,
            is_admin: selected_user.admin?,
            is_mypage: @session_user == selected_user
          }
        end.compact
        render json: generate_response(SUCCESS, body)
      end

      def update_icon
        unless user_tokens_for_update[:onetime]
          return render json: generate_response(FAILED, message: 'property onetime of token is empty')
        end

        onetime_session = login?(user_tokens_for_update[:onetime])
        unless onetime_session
          return render json: generate_response(FAILED, message: 'you are not logged in')
        end

        unless token_availavle?(user_tokens_for_update[:onetime])
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

        if update_icon_selected_user(selected_user)
          puts SUCCESS
          render json: generate_response(SUCCESS, message: 'user parameters are updated successfully')
        else
          puts FAILED
          render json: generate_response(FAILED, messages: selected_user.errors.messages)
        end
      end

      def update
        unless user_tokens[:onetime]
          return render json: generate_response(FAILED, message: 'property onetime of token is empty')
        end

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
          puts SUCCESS
          render json: generate_response(SUCCESS, message: 'user parameters are updated successfully')
        else
          puts FAILED
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

      def update_icon_selected_user(user)
        user.transaction do
          user.update!(icon: user_icon) if user_icon
          return true
        end
      rescue ActiveRecord::RecordInvalid
        false
      end

      def update_selected_user(user)
        user.transaction do
          user.update!(name: user_params[:name]) if user_params[:name]
          if user_params[:nickname]
            user.update!(nickname: user_params[:nickname])
          end
          if user_params[:explanation]
            user.update!(explanation: user_params[:explanation])
          end
          return true
        end
      rescue ActiveRecord::RecordInvalid
        false
      end

      def user_name
        params.permit(:id)[:id]
      end

      def user_icon
        p params.permit(:icon)[:icon]
      end

      def user_params
        return {} if params[:value].nil?

        params.require(:value).permit(:name, :nickname, :email, :password, :explanation)
      end

      def user_tokens_for_update
        return {} if params[:token].nil?

        ActionController::Parameters.new(JSON.parse(params.require(:token))).require(:token).permit(:onetime, :master)
      end

      def user_tokens
        return {} if params[:token].nil?

        params.require(:token).permit(:onetime, :master)
      end

      def user_token_from_get_params
        return nil if params[:token].nil?

        params.permit(:token)[:token]
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
