class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.integer :bestanswer_reward
      t.string :source_url
      t.string :state, default: :accepting
      t.text :body
      t.text :code
      t.timestamps
      t.string :user_id
    end
    add_foreign_key :posts, :users
  end
end
