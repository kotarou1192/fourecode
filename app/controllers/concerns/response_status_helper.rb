# frozen_string_literal: true

module ResponseStatusHelper
  extend ActiveSupport::Concern

  SUCCESS = 'SUCCESS'
  FAILED = 'FAILED'
  ERROR = 'ERROR'
  OLD_TOKEN = 'OLD_TOKEN'
end