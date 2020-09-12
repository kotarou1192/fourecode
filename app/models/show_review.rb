# frozen_string_literal: true

# reviewsとlink_reviewsをjoinした結果のビュー。
# ==Columns
# * post_id               :: integer
# * review_id             :: string
# * review_body           :: string
# * review_created_at     :: date
# * reviewer_id           :: string
# * reviewer_name
# * reviewer_nickname
# * reviewer_icon
# * review_thrown_coins   :: integer
# * response_id           :: integer
# * response_body         :: string
# * response_created_at   :: date
# * responder_id          :: integer
# * responder_name
# * responder_nickname
# * responder_icon
# * response_thrown_coins :: integer
class ShowReview < ApplicationRecord
  DEFAULT_MAX_CONTENTS_COUNT = 50
  # ポストに紐づくレビューとレスポンスを表現したハッシュの配列を返す
  # ==Argument
  # * post_id      :: integer
  # * max_contents :: 1ページに表示するコンテンツ量(integer)
  # * page         :: 何ページ目を表示するか(integer)
  # ==Returns
  # [
  #   {
  #     id,
  #     body,
  #     created_at,
  #     thrown_coins,
  #     reviewer: {
  #       name,
  #       nickname,
  #       icon
  #     }
  #     responses: [{
  #       id,
  #       body,
  #       created_at,
  #       thrown_coins,
  #       responder: {
  #         name,
  #         nickname,
  #         icon
  #       },
  #       ...
  #     }]
  #   }
  # ]
  #
  def self.show(post_id, max_contents = DEFAULT_MAX_CONTENTS_COUNT, page = 1)
    reviews_responses_mix = where(post_id: post_id).offset(max_contents * (page - 1)).limit(max_contents)
    reviews, responses = split_reviews_and_responses(reviews_responses_mix)
    merge_responses_to_reviews(reviews, responses)
  end

  # 上のshowのuser_name版。
  def self.show_by_user_name(user_name, max_contents = DEFAULT_MAX_CONTENTS_COUNT, page = 1)
    reviews_responses_mix = where(reviewer_name: user_name).or(where(responder_name: user_name))
                              .offset(max_contents * (page - 1)).limit(max_contents)
    reviews, responses = split_reviews_and_responses(reviews_responses_mix)
    merge_responses_to_reviews(reviews, responses)
  end

  # post_idに紐づくレビューとレスポンスの数を数える
  def self.count_reviews_and_responses(post_id)
    where(post_id: post_id).count
  end

  private

  def self.merge_responses_to_reviews(reviews, responses)
    reviews.map do |id, review|
      review.merge(responses: responses[id] || [])
    end
  end

  def self.split_reviews_and_responses(reviews_responses_mix)
    reviews = {}
    responses = {}
    reviews_responses_mix.each do |review_response_mix|
      current_review_id = review_response_mix.review_id

      reviews[current_review_id] = generate_review(review_response_mix)

      next unless review_response_mix.response_id

      responses[current_review_id] ||= []
      responses[current_review_id].push generate_response(review_response_mix)

    end
    [reviews, responses]
  end

  def self.generate_review(review_response_mix)
    {
      id: review_response_mix.review_id,
      body: review_response_mix.review_body,
      created_at: review_response_mix.review_created_at,
      thrown_coins: review_response_mix.review_thrown_coins,
      reviewer: {
        name: review_response_mix.reviewer_name,
        nickname: review_response_mix.reviewer_nickname,
        icon: icon_url(review_response_mix.reviewer_id, review_response_mix.reviewer_icon)
      }
    }
  end

  def self.generate_response(review_response_mix)
    {
      id: review_response_mix.response_id,
      body: review_response_mix.response_body,
      created_at: review_response_mix.response_created_at,
      thrown_coins: review_response_mix.response_thrown_coins,
      responder: {
        name: review_response_mix.responder_name,
        nickname: review_response_mix.responder_nickname,
        icon: icon_url(review_response_mix.responder_id, review_response_mix.responder_icon)
      }
    }
  end

  # ディレクトリそのまま書いてるのどうにかならないのかなと思いつつどうにもならなさそう
  def self.icon_url(user_id, file_name)
    return nil unless file_name

    "/uploads/user/icon/#{user_id}/#{file_name}"
  end
end
