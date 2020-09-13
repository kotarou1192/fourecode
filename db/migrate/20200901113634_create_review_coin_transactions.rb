class CreateReviewCoinTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :review_coin_transactions do |t|
      t.string :from
      t.string :to
      t.references :review, foreign_key: true
      t.integer :amount
      t.timestamps
    end
    add_foreign_key :review_coin_transactions, :users, { column: :from }
    add_foreign_key :review_coin_transactions, :users, { column: :to }
  end
end
