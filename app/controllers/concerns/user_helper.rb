# frozen_string_literal: true

# ユーザーをトークンから取り出す操作をまとめたモジュール
module UserHelper
  extend ActiveSupport::Concern
  include ResponseStatus
  include ResponseHelper
  include LoginHelper
  include ErrorMessageHelper
  include ErrorKeys

  SUCCESS = ResponseStatus::SUCCESS
  FAILED = ResponseStatus::FAILED

  # パラメーターにtokenがあり、かつ、そのトークンがセッションに存在し、期限が切れていなかったら返信パラメーターにis_mine=trueを入れる。
  # トークンの期限が切れていれば400エラーを発生させる
  def get_session_owner
    return unless user_token_from_flat_params

    onetime_session = login?(user_token_from_flat_params)
    if onetime_session&.available?
      @session_user = onetime_session.user
    elsif onetime_session && !onetime_session.available?
      old_token_response
    end
  end

  # post, putにおいてネストされたパラメーターからトークンを取り出し、
  # ログインしていてセッションがまだ有効なら
  # ユーザーをインスタンス変数に代入する関数
  def get_user
    unless user_token_from_nest_params[:onetime]
      message = 'onetime token is empty'
      key = ErrorKeys::TOKEN
      return error_response(key: key, message: message)
    end

    onetime_session = login?(user_token_from_nest_params[:onetime])
    unless onetime_session
      message = 'you are not logged in'
      key = ErrorKeys::LOGIN
      return error_response(key: key, message: message)
    end
    return old_token_response unless onetime_session.available?

    @user = onetime_session.user
  end

  # post, put用
  def user_token_from_nest_params
    return {} unless params[:token]

    params.require(:token).permit(:onetime)
  end

  # get, delete用
  def user_token_from_flat_params
    return nil unless params[:token]

    params.permit(:token)[:token]
  end
end
