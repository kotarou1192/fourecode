# frozen_string_literal: true

class User < ApplicationRecord
  include Discard::Model
  attr_accessor :activation_token, :password
  before_save :downcase_email
  before_create :create_activation_digest, :generate_uuid, :create_password_digest,
                :set_default_nickname, :grant_default_coin

  VALID_NAME_REGEX = /\A[a-zA-Z0-9-]+\z/
  validates :nickname, format: { with: VALID_NAME_REGEX }, presence: true, length: { maximum: 30 }, if: :nickname_exists?, allow_nil: true
  validates :name, format: { with: VALID_NAME_REGEX }, uniqueness: true, presence: true, length: { maximum: 30 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  validates :explanation, presence: true, length: { maximum: 255 }, allow_nil: true
  validates :coins, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  has_many :master_session, dependent: :destroy
  has_many :onetime_session, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :asked_users, dependent: :destroy
  has_one :password_reset_session, dependent: :destroy

  # deleteされていないPostのみを表示
  default_scope { kept }

  mount_uploader :icon, ImageUploader

  DEFAULT_COINS = 3000

  def self.new_token
    SecureRandom.hex(64)
  end

  def self.digest(string)
    Digest::SHA256.hexdigest(string)
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?

    User.digest(token) == digest
  end

  def activate
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def update_icon(base64_encoded_image)
    raise ArgumentError, 'image is empty' unless base64_encoded_image

    image = Base64.decode64(base64_encoded_image)

    file = Tempfile.open
    file.write image.force_encoding('UTF-8')

    update!(icon: file)
  ensure
    file.unlink
  end

  # パスワードを暗号化して代入する
  def create_password_digest
    self.password_digest = User.digest(password)
  end

  def self.find_users(keywords, page, max_content, is_shown_active_only = true)
    User.find_by_sql(User.arel_table
                       .project('result.name', 'result.nickname',
                                'result.explanation', 'result.icon',
                                'result.admin', 'result.activated')
                       .from(keywords_results_from_users(keywords).as('result'))
                       .where(set_user_state(true).and(active_user?(is_shown_active_only)))
                       .group('result.name', 'result.nickname',
                              'result.explanation', 'result.icon',
                              'result.admin', 'result.activated')
                       .order('count(*) desc') # ここに評価値みたいなのを入れるといいかもしれない
                       .take(max_content)
                       .skip(max_content * (page - 1))
                       .to_sql)
  end

  def self.count_search_results(keywords, is_shown_active_only = true)
    Post.count_by_sql(Post.arel_table
                        .project('count(*)')
                        .from(keywords_results_from_users(keywords).as('result'))
                        .where(set_user_state(true).and(active_user?(is_shown_active_only)))
                        .distinct('result.id')
                        .to_sql)
  end

  # 所持金からamountを引く
  # ==Argument
  # * amount :: Integer
  # ==Return
  # * 成功 # => true
  # * 失敗 # => 例外(RecordInvalid, ArgumentError)
  def take_coins(amount)
    raise ArgumentError if amount.negative?

    update!(coins: coins - amount)
  end

  # 所持金にamountを足す
  # ==Argument
  # * amount :: Integer
  # ==Return
  # * 成功 # => true
  # * 失敗 # => 例外(ArgumentError)
  def add_coins(amount)
    raise ArgumentError if amount.negative?

    update!(coins: coins + amount)
  end

  # 論理削除のコールバック
  after_discard do
    update_random_name
    update_random_email
    posts.discard_all
    MasterSession.destroy_sessions(self)
    discard
  end

  private

  # activeなUser（削除されていない）だけに絞り込みの場合は
  # 引数にTrueを入れる
  def self.active_user?(is_active = true)
    if is_active
      return (Arel::Table.new :result)[:discarded_at].eq nil
    end
    (Arel::Table.new :result)[:discarded_at].not_eq nil
  end

  # randomなUser名にアップデート
  def update_random_name
    1000.times do
      random_name = SecureRandom.hex(15)
      return if update!(name: random_name)
    end
    raise StandardError, 'failed to update user name randomly'
  end

  # randomなemailにアップデート
  def update_random_email
    1000.times do
      random_name = SecureRandom.hex(15)
      return if update!(email: "#{random_name}@4ecode.com")
    end
    raise StandardError, 'failed to update user email randomly'
  end

  def self.keywords_results_from_users(keywords, index = 0)
    keyword = keywords[index]
    user = User.arel_table
    users = user.project('*').from('users')
              .where(user[:name].matches(keyword))

    return users if keywords.size - 1 <= index

    Arel::Nodes::UnionAll.new(users, keywords_results_from_users(keywords, index + 1))
  end

  def self.set_user_state(is_activated)
    (Arel::Table.new :result)[:activated].eq(is_activated)
  end

  def nickname_exists?
    nickname != ''
  end

  def set_default_nickname
    return if self.nickname

    self.nickname = name
  end

  # メールアドレスをすべて小文字にする
  def downcase_email
    self.email = email.downcase
  end

  # 有効化トークンとダイジェストを作成および代入する
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

  # uuidを生成して代入する
  def generate_uuid
    100.times do
      @uuid = SecureRandom.uuid
      break unless User.find_by(id: @uuid)
    end
    self.id = @uuid
  end

  def grant_default_coin
    self.coins = DEFAULT_COINS
  end
end
