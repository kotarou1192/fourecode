# frozen_string_literal: true

class Api::V1::PostsController < ApplicationController
  include ErrorMessageHelper
  include ResponseHelper
  include LoginHelper

  SUCCESS = 'SUCCESS'
  FAILED = 'FAILED'
  ERROR = 'ERROR'
  OLD_TOKEN = 'OLD_TOKEN'

  before_action :get_user, only: %i[create update]

  # edit the post
  def update
    return unless @user

    post = Post.find(post_id)

    unless @user.id == post.user_id || @user.admin?
      message = 'this post is not yours. if you edit this post, you should be a admin'
      return render status: 400, json: generate_response(FAILED, message)
                                         .merge(error_messages(key: 'authority', message: message))
    end

    if post.update(update_params)
      return render json: generate_response(SUCCESS, 'post has been created successfully')
    end

    render status: 400, json: generate_response(FAILED, nil)
                                .merge(error_messages(error_messages: generate_error_messages_from_errors(post.errors.messages)))
  end

  # show the post
  def show
    # パラメーターにtokenがあり、かつ、そのトークンがセッションに存在し、期限が切れていなかったら返信パラメーターにis_mine=trueを入れる。
    # トークンの期限が切れていれば400エラーを発生させる
    if user_token_from_flat_params
      onetime_session = login?(user_token_from_flat_params)
      if onetime_session&.available?
        @session_user = onetime_session.user
      elsif onetime_session && !onetime_session.available?
        message = 'onetime token is unavailable'
        return render status: 400, json: generate_response(OLD_TOKEN, message: message)
                                           .merge(error_messages(key: 'token', message: message))
      end
    end

    selected_post = Post.find(post_id)
    unless selected_post
      message = 'not found'
      return render status: 404, json: generate_response(FAILED, message: message)
                                         .merge(error_messages(key: 'id', message: message))
    end

    render json: generate_response(SUCCESS, post_info(selected_post))
  end

  # create a post
  def create
    return unless @user

    post = @user.posts.new(post_params)
    if post.save
      return render json: generate_response(SUCCESS, 'post has been created successfully')
    end

    render status: 400, json: generate_response(FAILED, nil)
                                .merge(error_messages(error_messages: generate_error_messages_from_errors(post.errors.messages)))
  end

  private

  def get_user
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

    @user = onetime_session.user
  end

  def post_info(post)
    user = post.user
    {
      title: post.title,
      body: post.body,
      code: post.code,
      bestanswer_reward: post.bestanswer_reward,
      source_url: post.source_url,
      is_mine: @session_user ? user.id == @session_user.id : false,
      posted_by: {
        name: user.name,
        nickname: user.nickname,
        icon: user.icon.url
      }
    }
  end

  def user_token_from_flat_params
    return nil unless params[:token]

    params.permit(:token)[:token]
  end

  def post_id
    return nil unless params[:id]

    params.permit(:id)[:id]
  end

  def post_params
    params.require(:value).permit(:body, :code, :source_url, :bestanswer_reward, :title)
  end

  def update_params
    params.require(:value).permit(:body, :code, :source_url)
  end

  def user_token_from_nest_params
    return {} unless params[:token]

    params.require(:token).permit(:onetime)
  end
end
