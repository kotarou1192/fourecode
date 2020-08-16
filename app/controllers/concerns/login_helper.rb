# frozen_string_literal: true

module LoginHelper
  extend ActiveSupport::Concern
  def token_available?(onetime_token)
    onetime_session = login?(onetime_token)
    return false unless onetime_session&.available?

    true
  end

  def login?(onetime_token)
    OnetimeSession.find_by(token_digest: OnetimeSession.digest(onetime_token))
  end
end
