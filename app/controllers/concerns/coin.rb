# frozen_string_literal: true

# Coinの操作をまとめたモジュール。
# includeして使うこと。
module Coin
  extend ActiveSupport::Concern
  MAX_TRANSACTION_AMOUNT = 500

  module_function

  # 指定額を自分の財布から引いて相手の財布に送り、その履歴を保存するメソッド
  # == Args
  # * amount :: 贈与額(Integer)
  # * from   :: 渡す側のUserオブジェクト
  # * to     :: 渡す相手のUserオブジェクト
  # * review :: 対象のReviewまたはResponseのインスタンス
  # == Return
  # * 成功 # => true
  # * 失敗 # => false
  def throw(amount:, from:, review:)
    to = review.user
    return false if amount.negative? || amount > MAX_TRANSACTION_AMOUNT
    return false if ReviewCoinTransaction.already_threw?(review_id: review.id, user_id: from.id)
    return false if from.id == to.id

    to.transaction do
      to.add_coins(amount)
      from.take_coins(amount)
      review.update!(thrown_coins: review.thrown_coins + amount)
      ReviewCoinTransaction.create_record(review: review, from: from, amount: amount)
    rescue ActiveRecord::RecordInvalid || ArgumentError
      return false
    end
    true
  end

  # ユーザーからコインを奪う
  # ==Arguments
  # * amount :: Integer
  # * user   :: Userのインスタンス
  # ==Return
  # 成功 # => true
  # 失敗 # => false
  def take(amount:, user:)
    return false if amount.negative?

    begin
      user.take_coins(amount)
    rescue ActiveRecord::RecordInvalid || ArgumentError
      return false
    end
    true
  end

  # ユーザーにコインを授ける
  # ==Arguments
  # * amount :: Integer
  # * user   :: Userのインスタンス
  # ==Return
  # 成功 # => true
  # 失敗 # => false
  def add(amount:, user:)
    return false if amount.negative?

    begin
      user.add_coins(amount)
    rescue ActiveRecord::RecordInvalid || ArgumentError
      return false
    end
    true
  end
end
