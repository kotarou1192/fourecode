# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users, id: false do |t|
      t.string :id, limit: 36, null: false, primary_key: true
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :nickname
      t.boolean :admin, default: false
      t.string :activation_digest
      t.boolean :activated
      t.datetime :activated_at

      t.timestamps
    end
  end
end
