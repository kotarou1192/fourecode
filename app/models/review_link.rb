# frozen_string_literal: true

class ReviewLink < ApplicationRecord
  # レスポンスにレスポンスをすることはできない仕様なので、そのチェック
  # ==Argument
  # * review :: Review
  # ==Response
  # レビューのレスポンス # => true
  # レビュー # => false
  def self.response?(review)
    ReviewLink.exists?(to: review.id)
  end

  # アソシエーションのようなもの
  # 関連しているレコードをすべて削除する
  # ==Argument
  # * review :: Review
  # ==Response
  # * success => true
  # * failed => Error(何が帰ってくるのかはわからない)
  def self.destroy_all_dependency(review)
    transaction do
      where(from: review.id).each(&:destroy!)
      where(to: review.id).each(&:destroy!)
    end
    true
  end
end
