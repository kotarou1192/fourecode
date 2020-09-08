# frozen_string_literal: true

# レビューに関する操作を集めたコントローラー
class Api::V1::ReviewsController < ApplicationController
  include UserHelper

  MAXIMUM_CONTENTS_COUNT = 1000
  DEFAULT_CONTENTS_COUNT = 50

  before_action :get_user, only: %i[create]
  # before_action :get_session_owner, only: %i[show]

  # postに対するレビューを投稿するメソッド
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

  # postに紐づくレビューとレスポンスを取得するメソッド
  # 件数も表示する
  def show
    reviews_and_responses = ShowReview.show(post_id, max_contents_count, page_number)
    comments_count = ShowReview.count_reviews_and_responses(post_id)
    results = {
      reviews: reviews_and_responses,
      total_contents_count: comments_count,
      page_number: page_number
    }
    render json: generate_response(SUCCESS, results)
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

  def page_number
    return 1 unless params[:page_number]

    params.permit(:page_number)[:page_number]
  end

  def max_contents_count
    return DEFAULT_CONTENTS_COUNT unless params[:max_content]&.is_a?(Integer)
    return MAXIMUM_CONTENTS_COUNT if params[:max_content] > MAXIMUM_CONTENTS_COUNT

    params.permit(:max_content)[:max_content]
  end
end
