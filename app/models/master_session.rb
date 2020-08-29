# frozen_string_literal: true

class MasterSession < ApplicationRecord
  DATE_LIMIT = 30

  attr_accessor :token

  before_create :generate_token

  belongs_to :user
  has_many :onetime_session, dependent: :destroy

  def self.new_token
    SecureRandom.hex(64)
  end

  def self.digest(string)
    Digest::SHA256.hexdigest(string)
  end

  def available?
    created_at > DATE_LIMIT.days.ago
  end

  def self.destroy_old_sessions(user)
    master_sessions = MasterSession.where(user_id: user.id)
    ActiveRecord::Base.transaction do
      master_sessions.each do |master_session|
        master_session.destroy! unless master_session.available?
      end
    end
  end

  def self.destroy_sessions(user)
    master_sessions = MasterSession.where(user_id: user.id)
    ActiveRecord::Base.transaction do
      master_sessions.each(&:destroy!)
    end
  end

  private

  def generate_token
    100.times do
      self.token = user.id + '_' + MasterSession.new_token
      self.token_digest = MasterSession.digest(token)
      break unless MasterSession.find_by(token_digest: token_digest)
    end
  end
end
