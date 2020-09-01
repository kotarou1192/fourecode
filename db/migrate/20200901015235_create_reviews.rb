class CreateReviews < ActiveRecord::Migration[6.0]
  def change
    create_table :reviews do |t|
      t.text :body
      t.integer :thrown_coins, default: 0

      t.string :user_id
      t.references :post, foreign_key: true
      t.timestamps
    end
    add_foreign_key :reviews, :users
  end
end
