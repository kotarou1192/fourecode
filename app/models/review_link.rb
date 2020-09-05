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
end
