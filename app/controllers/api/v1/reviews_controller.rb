# frozen_string_literal: true

class Api::V1::ReviewsController < ApplicationController
  include UserHelper

  before_action :get_user, only: %i[create]
  # before_action :get_session_owner, only: %i[show]

  def create
    return unless @user

    post = Post.find(post_id)
    unless post
      message = 'the post is not found'
      return error_response json: generate_response(FAILED, message)
                                    .merge(error_messages(key: 'post_id', message: message))
    end

    if post.closed?
      message = 'the post has been closed'
      return error_response json: generate_response(FAILED, message)
                                    .merge(error_messages(key: 'closed', message: message))
    end

    review = Review.generate_record(body: body, post: post, user: @user)
    if review.save
      return render json: generate_response(SUCCESS, 'the review has been created successfully')
    end

    failed_to_create review
  end

  def show
    body = ShowReview.show(post_id)
    render json: generate_response(SUCCESS, body)
  end

  private

  def post_id
    return nil unless params[:id]

    params.permit(:id)[:id]
  end

  def body
    return nil unless params[:value] && params[:value][:body]

    params.require(:value).permit(:body)[:body]
  end
end
