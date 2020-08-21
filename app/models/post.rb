class Post < ApplicationRecord
  DEFAULT_REWARD = 100
  DEFINED_STATES = %w[accepting voting resolved].freeze

  before_save :set_default_reward
  validates :body, presence: true
  validates :code, presence: true

  has_many :asked_users, dependent: :destroy
  belongs_to :user

  def change_state(state)
    unless DEFINED_STATES.any?(state)
      raise ArgumentError, 'the state does not match any defined types'
    end

    update_attribute(:state, state)
  end

  def resolve
    change_state('resolved')
  end

  def resolved?
    state == 'resolved'
  end

  def ask_to(users)
    raise ArgumentError, 'argument type must be array' unless users.is_a? Array

    transaction do
      users.each do |user|
        answer_request = user.asked_users.new
        answer_request.post = self
        answer_request.save!
      end
    end
  end

  private

  def set_default_reward
    self.bestanswer_reward ||= DEFAULT_REWARD
  end
end
