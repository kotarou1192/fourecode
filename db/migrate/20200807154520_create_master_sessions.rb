# frozen_string_literal: true

class CreateMasterSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :master_sessions do |t|
      t.string :user_id
      t.string :token_digest
      t.timestamps
    end
    add_foreign_key :master_sessions, :users
  end
end
