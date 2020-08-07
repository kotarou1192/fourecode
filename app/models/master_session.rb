# frozen_string_literal: true

class MasterSession < ApplicationRecord
  DATE_LIMIT = 30

  attr_accessor :token

  before_create :generate_token

  belongs_to :user

  def self.new_token
    SecureRandom.hex(64)
  end

  def self.digest(string)
    Digest::SHA256.hexdigest(string)
  end

  def available?
    created_at > DATE_LIMIT.days.ago
  end

  private

  def generate_token
    100.times do
      self.token = MasterSession.new_token
      self.token_digest = MasterSession.digest(token)
      break unless MasterSession.find_by(token_digest: token_digest)
    end
  end
end
