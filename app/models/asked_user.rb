# frozen_string_literal: true

class AskedUser < ApplicationRecord
  belongs_to :user
  belongs_to :post
end
