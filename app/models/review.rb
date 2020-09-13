# frozen_string_literal: true

# 投稿に紐づくReviewを表すモデル
# Post has_many Reviews
# User has_many Reviews
class Review < ApplicationRecord

  BODY_MAX_CHARS = 5000

  belongs_to :post
  belongs_to :user
  has_many :review_coin_transactions, dependent: :destroy

  validates :body, presence: true, length: { maximum: BODY_MAX_CHARS }

  # 渡されたUserとPostをもとにReviewオブジェクトを生成して返す
  # == Args
  # * body    :: 本文
  # * user    :: Userオブジェクト
  # * post    :: Postオブジェクト
  # * primary :: boolean(レビューかレスポンスか)
  # == Return
  # 生成されたReviewオブジェクト
  def self.generate_record(body:, user:, post:, primary: true)
    review = post.reviews.new(body: body)
    review.user = user
    review.primary = primary
    review
  end

  # post_idに紐づくレビューとレスポンスの数を数える
  def self.count_by_post_id(post_id)
    where(post_id: post_id).count
  end

  def self.count_by_user_name(user_name)
    user = User.find_by(name: user_name)
    where(user_id: user ? user.id : nil).count
  end

  # 対象のレビューに指定のユーザーがリプライをするメソッド
  # ==Arguments
  # * body   :: String
  # * user   :: User
  # ==Return
  # 成功またはRecordInvalid # => Review
  # 失敗(レスポンスにレスしようとした) # => ArgumentError
  def reply(body:, user:)
    if ReviewLink.response?(self)
      raise ArgumentError, 'can not response to response'
    end

    post = self.post
    response = Review.generate_record(body: body, user: user, post: post, primary: false)

    transaction do
      response.save!
      ReviewLink.create!(from: id, to: response.id)
    rescue ActiveRecord::RecordInvalid
      return response
    end
    response
  end
end
