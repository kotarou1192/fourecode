class Api::V1::UsersSearchesController < SearchController

  # usersを検索する
  def search
    return if too_many_keywords?

    users = User.find_users(keywords, turn_pages, max_content)

    results = generate_results(users)
    hit_count = User.count_search_results(keywords)

    render_results(results, hit_count)
  end

  private

  def generate_results(users)
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
end
