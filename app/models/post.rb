class Post < ApplicationRecord
  DEFAULT_REWARD = 100

  before_save :set_default_reward
  validates :body, presence: true
  validates :code, presence: true

  belongs_to :user

  def change_state(state)
    defined_states = %w[accepting voting resolved]
    unless defined_states.any?(state)
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

  private

  def set_default_reward
    self.bestanswer_reward ||= DEFAULT_REWARD
  end
end
