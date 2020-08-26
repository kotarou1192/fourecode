class CreateAskedUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :asked_users do |t|
      t.string :user_id
      t.references :post, foreign_key: true
      t.timestamps
    end
    add_foreign_key :asked_users, :users
  end
end
