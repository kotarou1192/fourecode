# frozen_string_literal: true

class Api::V1::SearchController < ApplicationController
  include ErrorMessageHelper
  include ResponseHelper
  include LoginHelper

  SUCCESS = 'SUCCESS'
  FAILED = 'FAILED'
  ERROR = 'ERROR'
  OLD_TOKEN = 'OLD_TOKEN'
  SEARCH_RESULTS_COUNT = 30
  SEARCH_STRING_OFFSET = 30
  POST_STATUS = %w[accepting voting resolved].freeze
  MAX_KEYWORD_SIZE = 10

  # postsを検索する
  def search_posts
    # 空白区切りで入力された文字列を部分一致の記法を含んだ配列に変換する
    keywords = get_search_keyword.split(/[[:blank:]]/).map { |key| "%#{key}%" }
    if keywords.size > MAX_KEYWORD_SIZE
      return render status: 400, json: generate_response(ERROR, message: 'too many keywords')
                                         .merge(error_messages(key: 'keyword', message: 'too many keywords'))
    end

    posts_array = find_posts(keywords, turn_pages)

    results = generate_results(posts_array, keywords)

    body = {
      results: results,
      results_size: results.size,
      page_number: turn_pages
    }
    render json: generate_response(SUCCESS, body)
  end

  private

  # keyword_A UNION ALL keyword_B UNION ALL keyword_C UNION ALL .......
  def join_keywords_results(keywords, index = 0)
    keyword = keywords[index]
    post = Post.arel_table
    po = post.project('*').from('posts')
           .where(post[:title].matches(keyword)
                    .or(post[:code].matches(keyword))
                    .or(post[:body].matches(keyword)))

    return po if keywords.size - 1 <= index

    Arel::Nodes::UnionAll.new(po, join_keywords_results(keywords, index + 1))
  end

  def state
    (Arel::Table.new :result)[:state].matches(post_status)
  end

  def find_posts(keywords, page)
    Post.find_by_sql(Post.arel_table
                       .project('result.id', 'result.title',
                                'result.body', 'result.code',
                                'result.state', 'result.bestanswer_reward')
                       .from(join_keywords_results(keywords).as('result'))
                       .where(state)
                       .group('result.id', 'result.title',
                              'result.body', 'result.code',
                              'result.state', 'result.bestanswer_reward')
                       .order('count(*) desc, result.id desc') # ここに評価値みたいなのを入れるといいかもしれない
                       .take(max_content)
                       .skip(max_content * (page - 1))
                       .to_sql)
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
