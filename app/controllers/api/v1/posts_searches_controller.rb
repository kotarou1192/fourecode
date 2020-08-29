# frozen_string_literal: true

class Api::V1::PostsSearchesController < SearchController
  POST_STATUS = Post::DEFINED_STATES

  # postsを検索する
  def search
    return if too_many_keywords?

    posts_array = Post.find_posts(keywords, post_status, turn_pages, max_content)

    results = generate_results(posts_array, keywords)
    hit_count = Post.count_hit(keywords, post_status)

    render_results(results, hit_count)
  end

  private

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

  def post_status
    return '%_%' unless params[:status]&.is_a?(String)
    return '%_%' unless POST_STATUS.any?(params[:status])

    params.permit(:status)[:status]
  end
end
