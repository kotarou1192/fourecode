class Post < ApplicationRecord
  include Discard::Model
  DEFAULT_REWARD = 100
  DEFINED_STATES = %w[open closed].freeze
  MAX_REWARD = 500
  MIN_REWARD = 0
  BODY_MAX_CHARS = 10000
  CODE_MAX_CHARS = 10000
  TITLE_MAX_CHARS = 100
  SOURCE_URL_MAX_CHARS = 140

  before_save :set_default_reward
  validates :title, presence: true, length: { maximum: TITLE_MAX_CHARS }
  validates :body, presence: true, length: { maximum: BODY_MAX_CHARS }
  validates :code, presence: true, length: { maximum: CODE_MAX_CHARS }
  validates :bestanswer_reward, numericality: { greater_than_or_equal_to: MIN_REWARD, less_than_or_equal_to: MAX_REWARD }, allow_nil: true
  validates :source_url, presence: true, length: { maximum: SOURCE_URL_MAX_CHARS }, if: :url_exists?, allow_nil: true

  has_many :asked_users, dependent: :destroy
  has_many :reviews, dependent: :destroy
  belongs_to :user

  # deleteされていないPostのみを表示
  default_scope { kept }

  def change_state(state)
    unless DEFINED_STATES.any?(state)
      raise ArgumentError, 'the state does not match any defined types'
    end

    update_attribute(:state, state)
  end

  def close
    change_state('closed')
  end

  def closed?
    state == 'closed'
  end

  def ask_to(users)
    raise ArgumentError, 'argument type must be array' unless users.is_a? Array
    raise ActiveRecord::RecordNotSaved, 'this post not saved in the db' unless persisted?

    transaction do
      users.each do |user|
        answer_request = user.asked_users.new
        answer_request.post = self
        answer_request.save!
      end
    end
  end

  def self.count_search_results(keywords, post_state, author, is_shown_active_only = true)
    Post.count_by_sql(Post.arel_table
                        .project('count(*)')
                        .from(join_keywords_results(keywords).as('result'))
                        .where(set_post_state(post_state)
                                 .and(set_author(author))
                                 .and(active_post? is_shown_active_only))
                        .distinct('result.id')
                        .to_sql)
  end

  def self.find_posts(keywords, post_state, author, page, max_content, is_shown_active_only = true)
    Post.find_by_sql(Post.arel_table
                       .project('result.id', 'result.title',
                                'result.body', 'result.code',
                                'result.state', 'result.bestanswer_reward',
                                'result.user_id')
                       .from(join_keywords_results(keywords).as('result'))
                       .where(set_post_state(post_state)
                                .and(set_author(author))
                                .and(active_post? is_shown_active_only))
                       .group('result.id', 'result.title',
                              'result.body', 'result.code',
                              'result.state', 'result.bestanswer_reward',
                              'result.user_id')
                       .order('count(*) desc, result.id desc') # ここに評価値みたいなのを入れるといいかもしれない
                       .take(max_content)
                       .skip(max_content * (page - 1))
                       .to_sql)
  end

  private

  # keyword_A UNION ALL keyword_B UNION ALL keyword_C UNION ALL .......
  def self.join_keywords_results(keywords, index = 0)
    keyword = keywords[index]
    post = Post.arel_table
    po = post.project('*').from('posts')
           .where(post[:title].matches(keyword)
                    .or(post[:code].matches(keyword))
                    .or(post[:body].matches(keyword)))

    return po if keywords.size - 1 <= index

    Arel::Nodes::UnionAll.new(po, join_keywords_results(keywords, index + 1))
  end

  def self.set_post_state(post_status)
    (Arel::Table.new :result)[:state].matches(post_status)
  end

  # activeなPost（削除されていない）だけに絞り込みの場合は
  # 引数にTrueを入れる
  def self.active_post?(is_active = true)
    if is_active
      return (Arel::Table.new :result)[:discarded_at].eq nil
    end
    (Arel::Table.new :result)[:discarded_at].not_eq nil
  end

  # 引数はユーザー名か空文字かnil
  def self.set_author(author)
    user = User.find_by(name: author)
    if author.nil? || author.empty?
      return (Arel::Table.new :result)[:user_id].matches('%_%')
    end

    (Arel::Table.new :result)[:user_id].eq(user ? user.id : nil)
  end

  def set_default_reward
    self.bestanswer_reward ||= DEFAULT_REWARD
  end

  def url_exists?
    source_url != ''
  end
end
