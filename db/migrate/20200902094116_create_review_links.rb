class CreateReviewLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :review_links do |t|
      t.integer :from
      t.integer :to
      t.timestamps
    end
    add_foreign_key :review_links, :reviews, { column: :from }
    add_foreign_key :review_links, :reviews, { column: :to }
  end
end
