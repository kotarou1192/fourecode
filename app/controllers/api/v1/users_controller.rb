# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      include LoginHelper
      include ErrorMessageHelper
      include ResponseStatus
      include ErrorKeys

      def create
        @user = User.new(user_params)
        if @user.save
          @user.send_activation_email
          render json: generate_response(SUCCESS, message: 'activation mail has been sent')
        else
          failed_to_create @user
        end
      end

      def show
        token_valid?

        selected_user = User.find_by(name: user_name)

        unless selected_user&.activated?
          message = 'the user is not found'
          key = 'name'
          return error_response(key: key, message: message, status: 404)
        end

        render json: generate_response(SUCCESS, user_info(selected_user))
      end

      def update
        return unless authenticate

        selected_user = User.find_by(name: user_name)

        unless selected_user
          message = 'invalid user name'
          key = 'name'
          return error_response(key: key, message: message)
        end

        session_user = @user

        unless session_user.admin? || session_user == selected_user
          message = 'you are not admin'
          key = 'admin'
          return error_response(key: key, message: message)
        end

        if update_selected_user(selected_user)
          render json: generate_response(SUCCESS, message: 'user parameters are updated successfully')
        else
          failed_to_create selected_user
        end
      end

      def destroy
        return unless authenticate

        session_user = @user
        selected_user = User.find_by(name: user_name)
        unless selected_user
          message = 'invalid user name'
          key = 'name'
          return error_response(key: key, message: message)
        end

        unless session_user.admin? || session_user == selected_user
          message = 'you are not admin'
          key = 'admin'
          return error_response(key: key, message: message)
        end

        if selected_user.discard
          render json: generate_response(SUCCESS, message: 'user is deleted successfully')
        else
          failed_to_create selected_user
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
          is_mypage: @user == selected_user
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

      def generate_response(status, body)
        {
          status: status,
          body: body
        }
      end
    end
  end
end
