# frozen_string_literal: true

class SearchController < ApplicationController
  include ErrorMessageHelper
  include ResponseHelper
  include LoginHelper
  include ResponseStatusHelper

  MAXIMUM_CONTENTS_COUNT = 1000

  attr_accessor :max_keywords_count, :search_results_count, :search_string_offset
  attr_reader :keywords

  def initialize
    # デフォルトの１ページあたりの件数
    @search_results_count = 30
    # デフォルトの最大キーワード数
    @max_keywords_count = 10
    # take_stringで切り取るキーワードの左右の文字量
    @search_string_offset = 30
  end

  # 検索メソッドのインターフェース
  def search
    raise NotImplementedError, 'search is not implemented'
  end

  private

  def render_results(results, hit_count = 0)
    body = {
      results: results,
      results_size: results.size,
      page_number: turn_pages,
      hit_total: hit_count
    }
    render json: generate_response(SUCCESS, body)
  end

  # dataを渡すと結果を生成するメソッドのインターフェース
  def generate_results(data)
    raise NotImplementedError, 'generate_results is not implemented'
  end

  def get_keywords
    @keywords = get_search_keyword.split(/[[:blank:]]/).map { |key| "%#{key}%" }
  end

  def too_many_keywords?
    get_keywords
    if @keywords.size > @max_keywords_count
      render status: 400, json: generate_response(ERROR, message: 'too many keywords')
                                  .merge(error_messages(key: 'keyword', message: 'too many keywords'))
      return true
    end

    false
  end

  # 文字列とキーワードを渡すと、そのキーワードの周辺N文字を切り抜いてくれる関数。
  def take_string(string, first_keyword)
    index = string.index(first_keyword)
    index = 0 if index.nil?
    left = index - @search_string_offset
    left = 0 if left.negative?

    right = index + first_keyword.size + @search_string_offset
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
    return @search_results_count unless params[:max_content]&.is_a?(Integer)
    return MAXIMUM_CONTENTS_COUNT if params[:max_content] > MAXIMUM_CONTENTS_COUNT

    params.permit(:max_content)[:max_content]
  end
end
