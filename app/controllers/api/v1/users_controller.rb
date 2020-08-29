# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      include LoginHelper
      include ErrorMessageHelper
      include ResponseStatus

      def create
        @user = User.new(user_params)
        unless @user.valid?
          error_messages = generate_error_messages_from_errors(@user.errors.messages)
          return error_response json: generate_response(FAILED, nil)
                                        .merge(error_messages(error_messages: error_messages))
        end

        if @user.save
          @user.send_activation_email
          render json: generate_response(SUCCESS, message: 'activation mail has been sent')
        else
          error_messages = generate_error_messages_from_errors(@user.errors.messages)
          render error_response json: generate_response(ERROR, nil)
                                        .merge(error_messages(error_messages: error_messages))
        end
      end

      def show
        if user_token_from_get_params
          onetime_session = login?(user_token_from_get_params)
          if onetime_session && token_available?(user_token_from_get_params)
            @session_user = User.find_by(id: onetime_session.user_id)
          elsif !token_available?(user_token_from_get_params)
            message = 'onetime token is unavailable'
            return error_response json: generate_response(OLD_TOKEN, message: message)
                                          .merge(error_messages(key: 'token', message: message))
          end
        end

        selected_user = User.find_by(name: user_name)
        if user_name.nil?
          message = 'invalid user name'
          return error_response json: generate_response(FAILED, message: message)
                                        .merge(error_messages(key: 'name', message: message))
        end

        unless selected_user.activated?
          response_json = generate_response(FAILED, nil)
          response_json.merge(error_messages(key: 'id', message: 'a user is not found by the id'))
          return error_response(status: 404, json: response_json)
        end

        render json: generate_response(SUCCESS, user_info(selected_user))
      end

      def update
        unless user_tokens[:onetime]
          message = 'property onetime of token is empty'
          return error_response json: generate_response(FAILED, message: message)
                                        .merge(error_messages(key: 'token', message: message))
        end

        onetime_session = login?(user_tokens[:onetime])
        unless onetime_session
          message = 'you are not logged in'
          return error_response json: generate_response(FAILED, message: message)
                                        .merge(error_messages(key: 'login', message: message))
        end

        unless token_available?(user_tokens[:onetime])
          message = 'onetime token is too old'
          return error_response json: generate_response(OLD_TOKEN, message: message)
                                        .merge(error_messages(key: 'token', message: message))
        end

        selected_user = User.find_by(name: user_name)
        unless selected_user
          message = 'invalid user name'
          return error_response json: generate_response(FAILED, message: message)
                                        .merge(error_messages(key: 'name', message: message))
        end

        session_user = onetime_session.user

        unless session_user.admin? || session_user == selected_user
          message = 'you are not admin'
          return error_response json: generate_response(ERROR, message: message)
                                        .merge(error_messages(key: 'admin', message: message))
        end

        if update_selected_user(selected_user)
          render json: generate_response(SUCCESS, message: 'user parameters are updated successfully')
        else
          error_messages = generate_error_messages_from_errors(selected_user.errors.messages)
          error_response json: generate_response(FAILED, nil)
                                 .merge(error_messages(error_messages: error_messages))
        end
      end

      def destroy
        if user_token_from_get_params.nil?
          message = 'property onetime of token is empty'
          return error_response json: generate_response(FAILED, message: message)
                                        .merge(error_messages(key: 'token', message: message))
        end

        onetime_session = login?(user_token_from_get_params)
        unless onetime_session
          message = 'you are not logged in'
          return error_response json: generate_response(FAILED, message: message)
                                        .merge(error_messages(key: 'login', message: message))
        end

        unless token_available?(user_token_from_get_params)
          message = 'onetime token is too old'
          return error_response json: generate_response(OLD_TOKEN, message: message)
                                        .merge(error_messages(key: 'token', message: message))
        end

        session_user = onetime_session.user
        selected_user = User.find_by(name: user_name)
        unless selected_user
          message = 'invalid user name'
          return error_response json: generate_response(FAILED, message: message)
                                        .merge(error_messages(key: 'name', message: message))
        end

        unless session_user.admin? || session_user == selected_user
          message = 'you are not admin'
          return error_response json: generate_response(ERROR, message: message)
                                        .merge(error_messages(key: 'admin', message: message))
        end

        if selected_user.destroy
          render json: generate_response(SUCCESS, message: 'user is deleted successfully')
        else
          error_messages = generate_error_messages_from_errors(selected_user.errors.messages)
          error_response json: generate_response(FAILED, message: selected_user.errors.messages)
                                 .merge(error_messages(error_messages: error_messages))
        end
      end

      private

      def user_info(selected_user)
        {
          name: selected_user.name,
          nickname: selected_user.nickname,
          explanation: selected_user.explanation,
          icon: selected_user.icon,
          is_admin: selected_user.admin?,
          is_mypage: @session_user == selected_user
        }
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
          if user_params[:image] && user_params[:image][:base64_encoded_image]
            user.update_icon(user_params[:image][:base64_encoded_image])
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
        return {} if params[:value].nil?

        params.require(:value).permit(:name, :nickname, :email, :password, :explanation, image: %i[name base64_encoded_image])
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
