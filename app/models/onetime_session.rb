# frozen_string_literal: true

class OnetimeSession < ApplicationRecord
  DATE_LIMIT = 7

  attr_accessor :token

  before_create :generate_token

  belongs_to :master_session
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
      self.token = user.id + '_' + OnetimeSession.new_token
      self.token_digest = OnetimeSession.digest(token)
      break unless OnetimeSession.find_by(token_digest: token_digest)
    end
  end
end
