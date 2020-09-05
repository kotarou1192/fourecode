# frozen_string_literal: true

# レビューに対するコインの取引
class ReviewCoinTransaction < ApplicationRecord
  validates :review_id, uniqueness: { scope: :from }

  belongs_to :review

  # 既にそのレビューに対して投げ銭をしているか確認
  # ==Arguments
  # * review_id :: 調べるレビューのID
  # * user_id   :: 調べる渡したユーザーのID
  # ==Return
  # * 存在している   # => true
  # * 存在していない # => false
  def self.already_threw?(review_id:, user_id:)
    exists?(review_id: review_id, from: user_id)
  end

  # 取引履歴を作成する
  # ==Arguments
  # * review :: Reviewのインスタンス
  # * from   :: Userのインスタンス
  # * amount :: 取引額(Integer)
  # ==Return
  # * 成功 # => self
  # * 失敗 # => 例外を返す(引数が足りなかったりなど)
  def self.create_record(review:, from:, amount:)
    raise ArgumentError if amount.negative?

    to = review.user
    coin_transaction = new(from: from.id, to: to.id, amount: amount)
    coin_transaction.review = review
    coin_transaction.save!
    coin_transaction
  end
end
