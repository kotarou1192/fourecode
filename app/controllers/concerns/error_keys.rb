# frozen_string_literal: true

# Errorsに使うKeyをまとめたModule
module ErrorKeys
  extend ActiveSupport::Concern

  LINK = 'link'
  TOKEN = 'token'
  PASSWORD = 'password'
  EMAIL = 'email'
  ACCOUNT = 'account'
  KEYWORD = 'keyword'
  LOGIN = 'login'
  ID = 'id'
  AUTHORITY = 'authority'
  ADMIN = 'admin'
  CLOSED = 'closed'
  RESPONSE = 'response'
end
