# frozen_string_literal: true

class CreateOnetimeSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :onetime_sessions do |t|
      t.string :user_id
      t.string :token_digest
      t.timestamps
    end
    add_foreign_key :onetime_sessions, :users
  end
end
