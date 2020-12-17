# frozen_string_literal: true

class Api::V1::PostsController < ApplicationController
  include LoginHelper
  include ResponseStatus
  include ResponseHelper
  include ErrorKeys
  include ErrorMessageHelper

  before_action :authenticate, only: %i[create update show destroy]

  # destroy the post
  def destroy
    unless @user
      message = 'you are not login'
      key = ErrorKeys::LOGIN
      return error_response(key: key, message: message)
    end

    post = Post.find(post_id)
    unless post
      message = 'not found'
      key = ErrorKeys::ID
      return error_response(key: key, message: message, status: 404)
    end

    unless @user.id == post.user_id || @user.admin?
      message = 'this post is not yours. if you want to edit this post, you should be a admin'
      key = ErrorKeys::AUTHORITY
      return error_response(key: key, message: message)
    end

    if post.destroy
      return render json: generate_response(ResponseStatus::SUCCESS, 'the post has been deleted successfully')
    end

    render_error_message(post)
  end

  # edit the post
  def update
    return unless @user

    post = Post.find(post_id)
    unless post
      message = 'not found'
      key = ErrorKeys::ID
      return error_response(key: key, message: message, status: 404)
    end

    unless @user.id == post.user_id || @user.admin?
      message = 'this post is not yours. if you want to edit this post, you should be a admin'
      key = ErrorKeys::AUTHORITY
      return error_response(key: key, message: message)
    end

    if post.update(update_params)
      return render json: generate_response(ResponseStatus::SUCCESS, 'the post is updated successfully')
    end

    render_error_message(post)
  end

  # show the post
  def show
    post = Post.find(post_id)
    unless post
      message = 'not found'
      key = ErrorKeys::ID
      return error_response(key: key, message: message, status: 404)
    end

    render json: generate_response(ResponseStatus::SUCCESS, post_info(post))
  end

  # create a post
  def create
    return unless @user

    post = @user.posts.new(post_params)
    if post.save
      return render json: generate_response(ResponseStatus::SUCCESS, "post has been created successfully. post id is #{post.id}")
    end

    failed_to_create post
  end

  private

  def render_error_message(post)
    failed_to_create post
  end

  def post_info(post)
    user = post.user || User.new_deleted
    {
      title: post.title,
      body: post.body,
      state: post.state,
      bestanswer_reward: post.bestanswer_reward,
      source_url: post.source_url,
      is_mine: @user ? user.id == @user.id : false,
      posted_by: {
        name: user.name,
        nickname: user.nickname,
        icon: user.icon.url
      }
    }
  end

  def post_id
    return nil unless params[:id]

    params.permit(:id)[:id]
  end

  def post_params
    params.require(:value).permit(:body, :title)
  end

  def update_params
    params.require(:value).permit(:body, :code, :source_url)
  end
end
