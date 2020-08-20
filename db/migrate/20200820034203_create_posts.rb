class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.integer :bestanwser_reward
      t.string :source_url
      t.string :state, default: :accepting
      t.text :body
      t.text :code
      t.timestamps
    end
  end
end
