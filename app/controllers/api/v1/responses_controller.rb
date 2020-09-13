# frozen_string_literal: true

# レビューに対するレスポンスを取り扱うためのコントローラー
class Api::V1::ResponsesController < ApplicationController
  include UserHelper

  before_action :get_user, only: %i[create]

  # reviewに対するresponseを作成するメソッド
  def create
    return unless @user

    review = Review.find(review_id)

    unless review
      message = 'the review is not found'
      return error_response json: generate_response(FAILED, message)
                                    .merge(error_messages(key: 'review_id', message: message))
    end

    post = review.post

    if post.closed?
      message = 'the post has been closed'
      return error_response json: generate_response(FAILED, message)
                                    .merge(error_messages(key: 'closed', message: message))
    end

    return if response?(review)

    response = review.reply(body: body, user: @user)

    if response.persisted?
      return render json: generate_response(SUCCESS, 'the response has been created')
    end

    failed_to_create response
  end

  private

  # responseかreviewかを調べるためのメソッド
  def response?(review)
    if ReviewLink.response?(review)
      message = 'can not response to a response'
      error_response json: generate_response(FAILED, message)
                             .merge(error_messages(key: 'response', message: message))
      return true
    end
    false
  end

  def review_id
    return nil unless params[:review_id]

    params.permit(:review_id)[:review_id]
  end

  def body
    return nil unless params[:value] && params[:value][:body]

    params.require(:value).permit(:body)[:body]
  end
end
