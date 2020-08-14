# frozen_string_literal: true

class CreatePasswordResetSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :password_reset_sessions do |t|
      t.string :user_id
      t.string :token_digest
      t.timestamps
    end
    add_foreign_key :password_reset_sessions, :users
  end
end
