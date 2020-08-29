# frozen_string_literal: true

module ResponseStatus
  extend ActiveSupport::Concern

  SUCCESS = 'SUCCESS'
  FAILED = 'FAILED'
  ERROR = 'ERROR'
  OLD_TOKEN = 'OLD_TOKEN'
end