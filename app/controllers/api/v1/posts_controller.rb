# frozen_string_literal: true

class Api::V1::PostsController < ApplicationController
  include ErrorMessageHelper
  include ResponseHelper
  include LoginHelper

  SUCCESS = 'SUCCESS'
  FAILED = 'FAILED'
  ERROR = 'ERROR'
  OLD_TOKEN = 'OLD_TOKEN'

  # create a post
  def create
    unless user_token_from_nest_params[:onetime]
      return render status: 400, json: generate_response(FAILED, nil)
                                         .merge(error_messages(key: 'token', message: 'onetime token is empty'))
    end

    onetime_session = login?(user_token_from_nest_params[:onetime])
    unless onetime_session
      message = 'you are not logged in'
      return render status: 400, json: generate_response(FAILED, message: message)
                                         .merge(error_messages(key: 'login', message: message))
    end
    unless onetime_session.available?
      message = 'onetime token is too old'
      return render status: 400, json: generate_response(OLD_TOKEN, message: message)
                                         .merge(error_messages(key: 'token', message: message))
    end

    user = onetime_session.user
    post = user.posts.new(post_params)
    if post.save
      return render json: generate_response(SUCCESS, 'post has been created successfully')
    end

    render status: 400, json: generate_response(FAILED, nil)
                                .merge(error_messages(error_messages: generate_error_messages_from_errors(post.errors.messages)))
  end

  private

  def post_params
    params.require(:value).permit(:body, :code, :source_url, :bestanswer_reward, :title)
  end

  def user_token_from_nest_params
    return {} unless params[:token]

    params.require(:token).permit(:onetime)
  end
end
