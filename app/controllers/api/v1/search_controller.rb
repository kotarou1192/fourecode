# frozen_string_literal: true

class Api::V1::SearchController < ApplicationController
  include ErrorMessageHelper
  include ResponseHelper
  include LoginHelper
  include ResponseStatusHelper

  SEARCH_RESULTS_COUNT = 30
  SEARCH_STRING_OFFSET = 30
  POST_STATUS = Post::DEFINED_STATES
  MAX_KEYWORDS_COUNT = 10

  # postsを検索する
  def search_posts
    return if too_many_keywords?

    posts_array = Post.find_posts(@keywords, post_status, turn_pages, max_content)

    results = generate_results(posts_array, @keywords)

    render_results(results)
  end

  # usersを検索する
  def search_users
    return if too_many_keywords?

    users = User.find_users(@keywords, turn_pages, max_content)

    results = generate_user_results(users)

    render_results(results)
  end

  private

  def render_results(results)
    body = {
      results: results,
      results_size: results.size,
      page_number: turn_pages
    }
    render json: generate_response(SUCCESS, body)
  end

  def generate_user_results(users)
    users.map do |selected_user|
      {
        name: selected_user.name,
        nickname: selected_user.nickname,
        explanation: selected_user.explanation,
        icon: selected_user.icon.url,
        is_admin: selected_user.admin?
      }
    end
  end

  def get_keywords
    @keywords = get_search_keyword.split(/[[:blank:]]/).map { |key| "%#{key}%" }
  end

  def too_many_keywords?
    get_keywords
    if @keywords.size > MAX_KEYWORDS_COUNT
      render status: 400, json: generate_response(ERROR, message: 'too many keywords')
                                  .merge(error_messages(key: 'keyword', message: 'too many keywords'))
      return true
    end

    false
  end

  # レスポンスに入れる投稿のダイジェストの配列を生成する
  def generate_results(grouped_posts_array, keywords)
    grouped_posts_array.map do |post|
      body_result = take_string(post.body, keywords.first)
      code_result = take_string(post.code, keywords.first)
      {
        id: post.id,
        title: post.title,
        body: body_result,
        code: code_result,
        status: post.state,
        reward: post.bestanswer_reward
      }
    end
  end

  # 文字列とキーワードを渡すと、そのキーワードの周辺N文字を切り抜いてくれる関数。
  def take_string(string, first_keyword)
    index = string.index(first_keyword)
    index = 0 if index.nil?
    left = index - SEARCH_STRING_OFFSET
    left = 0 if left.negative?

    right = index + first_keyword.size + SEARCH_STRING_OFFSET
    right = string.size - 1 if right > first_keyword.size - 1

    size = right - left + 1
    string[left, size]
  end

  # パラメーターからキーワードを取得する
  # キーワードは空白区切り。
  def get_search_keyword
    return '' unless params[:keyword].is_a?(String)

    params.permit(:keyword)[:keyword]
  end

  # ページ。
  # 指定がなければ１ページめを表示する
  def turn_pages
    return 1 unless params[:page_number]&.is_a?(Integer)

    params.permit(:page_number)[:page_number]
  end

  # １ページに表示するコンテンツの量をパラメーターから取得する
  # 指定がなければ１ページの表示数はデフォルトを使用する
  def max_content
    return SEARCH_RESULTS_COUNT unless params[:max_content]&.is_a?(Integer)

    params.permit(:max_content)[:max_content]
  end

  def post_status
    return '%_%' unless params[:status]&.is_a?(String)
    return '%_%' unless POST_STATUS.any?(params[:status])

    params.permit(:status)[:status]
  end
end
