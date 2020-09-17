# frozen_string_literal: true

# ユーザーをトークンから取り出す操作をまとめたモジュール
module UserHelper
  extend ActiveSupport::Concern
  include ResponseStatus
  include ResponseHelper
  include LoginHelper
  include ErrorMessageHelper

  SUCCESS = ResponseStatus::SUCCESS
  FAILED = ResponseStatus::FAILED
  ERROR = ResponseStatus::ERROR
  OLD_TOKEN = ResponseStatus::OLD_TOKEN

  # パラメーターにtokenがあり、かつ、そのトークンがセッションに存在し、期限が切れていなかったら返信パラメーターにis_mine=trueを入れる。
  # トークンの期限が切れていれば400エラーを発生させる
  def get_session_owner
    return unless user_token_from_flat_params

    onetime_session = login?(user_token_from_flat_params)
    if onetime_session&.available?
      @session_user = onetime_session.user
    elsif onetime_session && !onetime_session.available?
      message = 'onetime token is too old'
      error_response json: generate_response(OLD_TOKEN, message: message)
                             .merge(error_messages(key: 'token', message: message))
    end
  end

  # post, putにおいてネストされたパラメーターからトークンを取り出し、
  # ログインしていてセッションがまだ有効なら
  # ユーザーをインスタンス変数に代入する関数
  def get_user
    unless user_token_from_nest_params[:onetime]
      return error_response json: generate_response(FAILED, nil)
                                    .merge(error_messages(key: 'token', message: 'onetime token is empty'))
    end

    onetime_session = login?(user_token_from_nest_params[:onetime])
    unless onetime_session
      message = 'you are not logged in'
      return error_response json: generate_response(FAILED, message: message)
                                    .merge(error_messages(key: 'login', message: message))
    end
    unless onetime_session.available?
      message = 'onetime token is too old'
      return error_response json: generate_response(OLD_TOKEN, message: message)
                                    .merge(error_messages(key: 'token', message: message))
    end

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
