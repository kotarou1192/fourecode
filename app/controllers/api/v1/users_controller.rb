# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      SUCCESS = 'SUCCESS'
      FAILED = 'FAILED'
      ERROR = 'ERROR'
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
        p params
      end

      def update
        p params
      end

      def destroy
        p params
      end

      private

      def user_params
        params.require(:value).permit(:name, :nickname, :email, :password)
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
