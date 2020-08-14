# frozen_string_literal: true

class PasswordResetSession < ApplicationRecord
  HOURS_LIMIT = 2

  attr_accessor :token

  belongs_to :user

  before_create :generate_token

  def self.new_token
    SecureRandom.hex(64)
  end

  def self.digest(string)
    Digest::SHA256.hexdigest(string)
  end

  def available?
    created_at > HOURS_LIMIT.hours.ago
  end

  private

  def generate_token
    100.times do
      self.token = PasswordResetSession.new_token
      self.token_digest = PasswordResetSession.digest(token)
      break unless PasswordResetSession.find_by(token_digest: token_digest)
    end
  end
end
